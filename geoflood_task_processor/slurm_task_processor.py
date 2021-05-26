## GeoFlood preprocessing 1m DEM data
## Author: Daniel Hardesty Lewis


## Import needed modules
import argparse
import subprocess
import pandas as pd
from pathlib import Path, PurePath
import os
import shutil
from threading import Thread
from collections import deque
import time
import gc
import sys
from io import BytesIO
import getpass
import shlex


def argparser():
    ## Define input and output file locations

    parser = argparse.ArgumentParser()

    ## path of HAND-TauDEM sbatch script
    parser.add_argument(
        "-b",
        "--path_sbatch",
        type=str,
        help="path of HAND-TauDEM sbatch script"
    )
    ## number of jobs on each node
    parser.add_argument(
        "-j",
        "--jobs",
        type=int,
        help="number of jobs on each node"
    )
    ## path of the HAND-TauDEM bash script
    parser.add_argument(
        "-s",
        "--path_sh",
        type=str,
        help="path of the HAND-TauDEM bash script"
    )
    ## path of the HAND-TauDEM log file
    parser.add_argument(
        "-l",
        "--path_log",
        type=str,
        help="path of the HAND-TauDEM log file"
    )
    ## path of the HAND-TauDEM log file's parent directory
    parser.add_argument(
        "-d",
        "--path_log_dir",
        type=str,
        help="path of the HAND-TauDEM log file's parent directory"
    )
    ## path of the HAND-TauDEM commands script
    parser.add_argument(
        "-c",
        "--path_cmds",
        type=str,
        help="path of the HAND-TauDEM commands script"
    )
    ## path of the HAND-TauDEM command outputs list
    parser.add_argument(
        "-o",
        "--path_cmd_outputs",
        type=str,
        help="path of the HAND-TauDEM command outputs list"
    )
    ## path of the HAND-TauDEM commands configuration file
    parser.add_argument(
        "-r",
        "--path_rc",
        type=str,
        help="path of the HAND-TauDEM commands configuration file"
    )
    ## minutes between scheduler checks
    parser.add_argument(
        "-m",
        "--minutes",
        type=int,
        help="minutes between scheduler checks"
    )
    ## Input DEMs to parse
    parser.add_argument(
        "-t",
        "--task_limit",
        type=int,
        help="Limit on tasks processed at once"
    )
    ## Remote directory to upload to
    parser.add_argument(
        "--remote_dir_inputs",
        type=str,
        help="Remote directory to upload to"
    )
    ## Remote directory to upload to
    parser.add_argument(
        "--local_dir_inputs",
        type=str,
        help="Local directory to download to"
    )
    ## Remote directory to upload to
    parser.add_argument(
        "--remote_dir_outputs",
        type=str,
        help="Remote directory to upload to"
    )
    ## Remote directory to upload to
    parser.add_argument(
        "--local_dir_outputs",
        type=str,
        help="Local directory to download to"
    )
    ## Input DEMs to parse
    parser.add_argument(
        "pos",
        nargs='*',
        type=str,
        help="Input DEMs to parse"
    )

    args = parser.parse_args()

    ## Check that the required input files have been defined
    if not args.path_sbatch:
        parser.error('-b --path_sbatch HAND sbatch file not specified')
    if not args.jobs:
        parser.error('-j --jobs Number of jobs per node not specified')
    if not args.path_sh:
        parser.error('-s --path_sh HAND Bash script file not specified')
    if not args.path_log:
        parser.error('-l --path_log HAND log file not specified')
    if not args.path_cmds:
        parser.error('-c --path_cmds HAND Bash commands file not given')
    if not args.path_cmd_outputs:
        parser.error('-o --path_cmd_outputs Command outputs not given')
    if not args.path_rc:
        parser.error('-r --path_rc HAND configuration file not specified')
    if not args.minutes:
        parser.error('-m --minutes Minutes between task processor checks')
    if not args.remote_dir_inputs:
        parser.error('--remote_dir_inputs Remote directory to upload to')
    if not args.local_dir_inputs:
        parser.error('--local_dir_inputs Local directory to download to')
    if not args.remote_dir_outputs:
        parser.error('--remote_dir_outputs Remote directory to upload to')
    if not args.local_dir_outputs:
        parser.error('--local_dir_outputs Local directory to download to')
    if not args.pos:
        parser.error('Input DEMs not specified')

    return(args)


class TaskProcessor(Thread):
    """
    https://stackoverflow.com/a/53505397
    CC BY-SA 4.0 2018 Darkonaut
    Processor class which monitors memory usage for running tasks (processes).
    Suspends execution for tasks surpassing `max_b` and completes them one
    by one, after behaving tasks have finished.
    """

    def __init__(self, tasks):

        super().__init__()

        if args.task_limit:
            self.qlim_total = args.task_limit
        else:
            self.qlim_total = 50

        self.tasks = deque(tasks)

        self._running_tasks = []

        self.user = getpass.getuser()
        self.queue = 'development'

    def run(self):
        """Main-function in new thread."""
        self._update_running_tasks()
        self._monitor_running_tasks()

    def _bashCmdStr(self):
        """Structure sbatch command after evaluating current queue usage"""
        self.bashCmd = (
            "sbatch" +
                " -N 1 " +
                args.path_sbatch +
                    " -j "                 + str(args.jobs) +
                    " --path_sh "          + args.path_sh +
                    " --path_log "         + self.logfile.__str__() +
                    " --path_cmds "        + args.path_cmds +
                    " --path_cmd_outputs " + args.path_cmd_outputs +
                    " --path_rc "          + args.path_rc +
                    " --queue "            + self.queue +
                    " --start_time "       + str(self.start_time) +
                    " " + self.p
        )

    def _subprocess_Popen(self):
        """Query squeue for all running jobs for this user"""
        process = subprocess.Popen(
            shlex.split(self.bashCmd),
            stdout = subprocess.PIPE,
            stderr = subprocess.PIPE
        )
        self.output, self.error = process.communicate()

    def _squeue(self):
        """Query squeue for all running jobs for this user"""
        self.bashCmd = (
            "squeue" +
                " -u " + self.user +
                ' -o "%.18i %.9P %.8j %.8u %.2t %.10M %.6D"'
        )
        self._subprocess_Popen()
        if self.error == b'':
            squeue = pd.read_csv(BytesIO(self.output),sep="\s+")
            self._running_tasks_len = squeue.shape[0]
        else:
            print(self.bashCmd)
            print(self.error)
            print('BREAK at line 211')

    def _logcsv(self):
        """Query log for this task"""
        self.logcsv = pd.read_csv(
            self.logfile,
            index_col = 'index',
            dtype = {
                'pid' : int,
                'start_time' : int,
                'job_id' : int,
                'queue' : str,
                'elapsed_time' : int,
                'error_long_queue_timeout' : bool,
                'complete' : bool,
                'last_cmd' : str
            }
        )
        self.idx = self.logcsv.index[0]

    def _running_tasks_dict(self):
        """Construct info dict for this task"""
        self.running_tasks_dict = {
            self.job_id : {
                'queue' : self.queue,
                'dem' : self.p,
                'log' : self.logfile,
                'remote_dirs_inputs' : self.remote_dirs_inputs,
                'local_dirs_inputs' : self.local_dirs_inputs,
                'remote_dirs_outputs' : self.remote_dirs_outputs,
                'local_dirs_outputs' : self.local_dirs_outputs
            }
        }

    def _copytree(self, src, dst, symlinks=False, ignore=None):
        print('within_copytree: ',src,type(src))
        for item in os.listdir(src):
            s = os.path.join(src, item)
            d = os.path.join(dst, item)
            if os.path.isdir(s):
                shutil.copytree(s, d, symlinks, ignore)
            else:
                shutil.copy2(s, d)

    def _update_running_tasks(self):
        """Start new tasks if we have less running tasks than cores."""

        self._squeue()
        while (
            ## Stay under overall Stampede2 job limit
            len(self._running_tasks) < self.qlim_total and
            self._running_tasks_len < self.qlim_total and
            len(self.tasks) > 0
        ):

            gc.collect()

            self.p = self.tasks.popleft()

            ## TODO Make specifying log file name optional
            self.logfile = Path(args.path_log_dir).joinpath(
                Path(self.p).stem,
                args.path_log
            )
            if not self.logfile.parent.absolute().is_dir():
                Path(self.logfile.parent.absolute()).mkdir(
                    parents = True,
                    exist_ok = True
                )
            if not self.logfile.is_file():
                self.logcsv = pd.DataFrame(
                    index = [int()],
                    data = {
                        'pid' : [int()],
                        'start_time' : [int()],
                        'job_id' : [0],
                        'queue' : ['development'],
                        'elapsed_time' : [args.minutes * 60 + 1],
                        'error_long_queue_timeout' : [False],
                        'complete' : [False],
                        'last_cmd' : ['touch'],
                        'exit_code' : [0]
                    }
                )
                self.logcsv.index.names = ['index']
                self.logcsv.to_csv(self.logfile)

            self._logcsv()

            self.remote_dirs_inputs = list(
                Path(args.remote_dir_inputs).rglob(self.p)
            )
            self.local_dirs_inputs = [
                PurePath(args.local_dir_inputs,*fn.parts[-2:])
                for fn
                in self.remote_dirs_inputs
            ]
            [
                Path(fn).mkdir(parents=True, exist_ok=True)
                for fn
                in self.local_dirs_inputs
            ]
            [
                self._copytree(src,dst)
                for src,dst
                in zip(self.remote_dirs_inputs,self.local_dirs_inputs)
            ]

            self.remote_dirs_outputs = list(
                Path(args.remote_dir_outputs).rglob(self.p)
            )
            self.local_dirs_outputs = [
                PurePath(args.local_dir_outputs,*fn.parts[-2:])
                for fn
                in self.remote_dirs_outputs
            ]
            [
                Path(fn).mkdir(parents=True, exist_ok=True)
                for fn
                in self.local_dirs_outputs
            ]
            [
                self._copytree(src,dst)
                for src,dst
                in zip(self.remote_dirs_outputs,self.local_dirs_outputs)
            ]

            self.start_time = int(time.time())

            self._bashCmdStr()
            self._subprocess_Popen()
            if (
                self.error == b'' and
                'FAILED' not in self.output.decode("utf-8")
            ):
                self.job_id = int(self.output.split()[-1])
            else:
                print('BREAK at line 389')
                print(self.bashCmd)
                print(self.output)
                print(self.error)
                break

            self._running_tasks_dict()

            self._running_tasks.append(
                self.running_tasks_dict
            )
            print(f'Started process: {self._running_tasks[-1]}')

            self._squeue()

    def _monitor_running_tasks(self):
        """
        Monitor running tasks. Replace completed tasks and suspend tasks
        which exceed the memory threshold `self.max_b`.
        """

        # loop while we have running or non-started tasks
        while self._running_tasks or self.tasks:
            # Without it, p.is_running() below on Unix would not return
            # `False` for finished processes.
            self._update_running_tasks()
            actual_tasks = self._running_tasks.copy()

            print("actual_tasks")
            print(actual_tasks)
            for p in actual_tasks:

                key = list(p.keys())[0]
                print("task")
                print(p)

                self.bashCmd = (
                    "squeue" +
                        " -j " + str(key) +
                        ' -o "%.18i %.9P %.8j %.8u %.2t %.10M %.6D"'
                )
                self._subprocess_Popen()
                print("self.output")
                print(self.output)
                print("self.error")
                print(self.error)
                if self.error != b'':  ## process has finished

                    print("key")
                    print(key)

                    [
                        self._copytree(src,dst)
                        for src,dst
                        in zip(p[key]['local_dirs_outputs'],p[key]['remote_dirs_outputs'])
                    ]
                    os.sync()
                    [
                        shutil.rmtree(fn,ignore_errors=True)
                        for fn
                        in p[key]['local_dirs_inputs']
                    ]
                    [
                        shutil.rmtree(fn,ignore_errors=True)
                        for fn
                        in p[key]['local_dirs_outputs']
                    ]
                    
                    self._running_tasks.remove(p)
                    print(f'Removed finished process: {p}')

                    self.logfile = p[key]['log']
                    self._logcsv()
                    if self.logcsv.loc[self.idx,'complete'] != True:
                        self.tasks.append(p[key]['dem'])
                        print(f'Added incomplete process: {p}')

                else:

                    print('CONTINUE at line 498')
                    print(self.bashCmd)
                    print(self.error)
                    continue

            time.sleep(float(args.minutes * 60))


def main():

    global args

    args = argparser()

    start_time = time.time()

    arguments = args.pos
    pool = TaskProcessor(tasks = arguments)
    pool.start()
    pool.join()

    print("HAND processed for all HUCs")
    print("-----", int((time.time()-start_time)*1000), "-----")


if __name__ == "__main__":
    main()


