#!/bin/bash
##
##------------------------------------------------------------------------------
## Usage: hand-taudem.sh
##
## Workflow that returns height-above-nearest-drainage (HAND) from source data  
## Author: Daniel Hardesty Lewis
## Copyright: Copyright 2020, Daniel Hardesty Lewis
## Credits: Daniel Hardesty Lewis
## License: GPLv3
## Version: 3.1.2
## Maintainer: Daniel Hardesty Lewis
## Email: dhl@tacc.utexas.edu
## Status: Production
##
## This Stampede-2 job script is designed to create a HAND-TauDEM session on 
## KNL long nodes through the SLURM batch system. Once the job
## is scheduled, check the output of your job (which by default is
## stored in your home directory in a file named hand-taudem.out)
##
## Aspects of this scripts were incorporated from `job.vnc`
##  located at /share/doc/slurm/job.vnc on stampede2.tacc.utexas.edu
##
## Note: you can fine tune the SLURM submission variables below as
## needed.  Typical items to change are the runtime limit, location of
## the job output, and the allocation project to submit against (it is
## commented out for now, but is required if you have multiple
## allocations).  
##
## To submit the job, issue: "sbatch hand-taudem.sbatch.sh" 
##
## For more information, please consult the User Guide at: 
##
## https://portal.tacc.utexas.edu/user-guides/stampede2
##-----------------------------------------------------------------------------
##


##------------------------------------------------------------------------------
##------- You normally should not need to edit anything below this point -------
##------------------------------------------------------------------------------

args=( )
for arg; do
    case "$arg" in
        --path_taskproc )    args+=( -t ) ;;
        --job )              args+=( -j ) ;;
        --path_sbatch )      args+=( -b ) ;;
        --path_sh )          args+=( -s ) ;;
        --path_log )         args+=( -l ) ;;
        --path_log_dir )     args+=( -d ) ;;
        --path_cmds )        args+=( -c ) ;;
        --path_cmd_outputs ) args+=( -o ) ;;
        --path_rc )          args+=( -r ) ;;
        --minutes )          args+=( -m ) ;;
        --task_limit )       args+=( -q ) ;;
        --remote_dir_inputs )  args+=( -e ) ;;
        --local_dir_inputs )   args+=( -a ) ;;
        --remote_dir_outputs ) args+=( -f ) ;;
        --local_dir_outputs )  args+=( -g ) ;;
        *)                   args+=( "$arg" ) ;;
    esac
done

set -- "${args[@]}"

ARGS=""
while [ $# -gt 0 ]; do
    unset OPTIND
    unset OPTARG
    while getopts "t:j:b:s:l:d:c:o:r:m:q:e:a:f:g:" OPTION; do
        : "$OPTION" "$OPTARG"
        case $OPTION in
            t) PATH_TASKPROC="$(readlink -f $OPTARG)";;
            j) JOBS="$OPTARG";;
            b) PATH_SBATCH="$(readlink -f $OPTARG)";;
            s) PATH_SH="$(readlink -f $OPTARG)";;
            l) PATH_LOG="$OPTARG";;
            d) PATH_LOG_DIR="$(readlink -f $OPTARG)";;
            c) PATH_CMDS="$(readlink -f $OPTARG)";;
            o) PATH_CMD_OUTPUTS="$(readlink -f $OPTARG)";;
            r) PATH_RC="$(readlink -f $OPTARG)";;
            m) MINUTES="$OPTARG";;
            q) TASK_LIMIT="$OPTARG";;
            e) REMOTE_DIR_INPUTS="$(readlink -f $OPTARG)";;
            a) LOCAL_DIR_INPUTS="$(readlink -f $OPTARG)";;
            f) REMOTE_DIR_OUTPUTS="$(readlink -f $OPTARG)";;
            g) LOCAL_DIR_OUTPUTS="$(readlink -f $OPTARG)";;
        esac
    done
    shift $((OPTIND-1))
    ARGS="${ARGS} $1 "
    shift
done


if [ -z ${TASK_LIMIT} ]; then
    TASK_LIMIT=50;
fi

python3 ${PATH_TASKPROC} --path_sbatch ${PATH_SBATCH} \
                         -j ${JOBS} \
                         --path_sh ${PATH_SH} \
                         --path_log ${PATH_LOG} \
                         --path_log_dir ${PATH_LOG_DIR} \
                         --path_cmds ${PATH_CMDS} \
                         --path_cmd_outputs ${PATH_CMD_OUTPUTS} \
                         --path_rc ${PATH_RC} \
                         --minutes ${MINUTES} \
                         --task_limit ${TASK_LIMIT} \
                         --remote_dir_inputs ${REMOTE_DIR_INPUTS} \
                         --local_dir_inputs ${LOCAL_DIR_INPUTS} \
                         --remote_dir_outputs ${REMOTE_DIR_OUTPUTS} \
                         --local_dir_outputs ${LOCAL_DIR_OUTPUTS} \
                         $ARGS


