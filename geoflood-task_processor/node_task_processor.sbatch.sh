#!/bin/bash
##
##------------------------------------------------------------------------------
## Usage:
##  sbatch node_task_processor.sbatch.sh --job 1 --path_img ../geoflood_docker_tacc.sif --path_sh node_task_processor.sh --path_log geoflood_singularity.log --path_cmds workflow_commands-geoflood_singularity.sh --path_cmd_outputs workflow_outputs-geoflood_singularity.txt --path_rc workflow_configuration-geoflood_singularity.sh --queue development --start_time $(date -u +%s) HUC1 HUC2 HUC3
##
## Workflow that returns height-above-nearest-drainage (HAND) from source data  
## Author: Daniel Hardesty Lewis
## Copyright: Copyright 2020, Daniel Hardesty Lewis
## Credits: Daniel Hardesty Lewis
## License: GPLv3
## Version: 1.0.0
## Maintainer: Daniel Hardesty Lewis
## Email: dhl@tacc.utexas.edu
## Status: Production
##
## This Stampede-2 job script is designed to create a GeoFlood session on 
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
#SBATCH -J geoflood.%j    # Job name
#SBATCH -o geoflood.o%j    # Name of stdout output file (%j expands to jobId)
#SBATCH -e geoflood.e%j    # Name of stderr error file (%j expands to jobId)
#SBATCH -p normal         # Queue name
#SBATCH -N 1                  # Total number of nodes requested (48 cores/node)
#SBATCH -n 67                 # Total number of mpi tasks requested
#SBATCH -t 48:00:00          # Run time (hh:mm:ss) - 2 hours
#SBATCH -A PT2050-DataX
#SBATCH --reservation PT2050

##------------------------------------------------------------------------------
##------- You normally should not need to edit anything below this point -------
##------------------------------------------------------------------------------


args=( )
for arg; do
    case "$arg" in
        --job )                   args+=( -j ) ;;
        --job_id )                args+=( -d ) ;;
        --path_img )         args+=( -i ) ;;
        --path_sh )          args+=( -s ) ;;
        --path_log )         args+=( -l ) ;;
        --path_cmds )        args+=( -c ) ;;
        --path_cmd_outputs ) args+=( -o ) ;;
        --path_rc )          args+=( -r ) ;;
        --queue )                 args+=( -q ) ;;
        --start_time )            args+=( -t ) ;;
        *)                        args+=( "$arg" ) ;;
    esac
done

set -- "${args[@]}"

ARGS=""
while [ $# -gt 0 ]; do
    unset OPTIND
    unset OPTARG
    while getopts "j:d:i:s:l:c:o:r:q:t:" OPTION; do
        : "$OPTION" "$OPTARG"
        case $OPTION in
            j) JOBS="$OPTARG";;
            d) SLURM_JOB_ID="$OPTARG";;
            i) PATH_IMG="$(readlink -f $OPTARG)";;
            s) PATH_SH="$(readlink -f $OPTARG)";;
            l) PATH_LOG="$OPTARG";;
            c) PATH_CMDS="$(readlink -f $OPTARG)";;
            o) PATH_CMD_OUTPUTS="$(readlink -f $OPTARG)";;
            r) PATH_RC="$(readlink -f $OPTARG)";;
            q) QUEUE="$OPTARG";;
            t) START_TIME="$OPTARG";;
        esac
    done
    shift $((OPTIND-1))
    ARGS="${ARGS} $1 "
    shift
done


module unload xalt
module load tacc-singularity

#singularity exec ${PATH_IMG} \
bash --noprofile \
     --norc \
     -c "${PATH_SH} -j $JOBS --job_id ${SLURM_JOB_ID} --queue ${QUEUE} --start_time ${START_TIME} --path_rc ${PATH_RC} --path_cmds ${PATH_CMDS} --path_cmd_outputs ${PATH_CMD_OUTPUTS} --path_log ${PATH_LOG} $ARGS"


