#!/bin/bash
##
##------------------------------------------------------------------------------
## Usage: hand-taudem.sh
##  initiate_slurm_task-processor.sh --path_taskproc slurm_task_processor.py -j 1 --path_sbatch node_task_processor.sbatch.sh --path_cmds workflow_commands-hand_taudem.sh --path_cmd_outputs workflow_outputs-hand_taudem.txt --path_log hand_taudem.log --path_rc workflow_configuration-hand_taudem.sh --path_img ../hand_taudem_docker_latest.sif --path_sh node_task_processor.sh --minutes 15 ./Travis-10m-[0-9]/Travis-DEM-10m-HUC120902050408buf.tif
##
## Workflow that returns height-above-nearest-drainage (HAND) from source data  
## Author: Daniel Hardesty Lewis
## Copyright: Copyright 2021, Daniel Hardesty Lewis
## Credits: Daniel Hardesty Lewis
## License: GPLv3
## Version: 1.0.0
## Maintainer: Daniel Hardesty Lewis
## Email: dhl@tacc.utexas.edu
## Status: Production


args=( )
for arg; do
    case "$arg" in
        --path_taskproc )    args+=( -t ) ;;
        --job )                   args+=( -j ) ;;
        --path_sbatch )      args+=( -b ) ;;
        --path_img )         args+=( -i ) ;;
        --path_sh )          args+=( -s ) ;;
        --path_log )         args+=( -l ) ;;
        --path_log_dir )          args+=( -d ) ;;
        --path_cmds )        args+=( -c ) ;;
        --path_cmd_outputs ) args+=( -o ) ;;
        --path_rc )          args+=( -r ) ;;
        --minutes )               args+=( -m ) ;;
        *)                        args+=( "$arg" ) ;;
    esac
done

set -- "${args[@]}"

ARGS=""
while [ $# -gt 0 ]; do
    unset OPTIND
    unset OPTARG
    while getopts "t:j:b:i:s:l:d:c:o:r:m:" OPTION; do
        : "$OPTION" "$OPTARG"
        case $OPTION in
            t) PATH_TASKPROC="$(readlink -f $OPTARG)";;
            j) JOBS="$OPTARG";;
            b) PATH_SBATCH="$(readlink -f $OPTARG)";;
            i) PATH_IMG="$(readlink -f $OPTARG)";;
            s) PATH_SH="$(readlink -f $OPTARG)";;
            l) PATH_LOG="$OPTARG";;
            d) PATH_LOG_DIR="$(readlink -f $OPTARG)";;
            c) PATH_CMDS="$(readlink -f $OPTARG)";;
            o) PATH_CMD_OUTPUTS="$(readlink -f $OPTARG)";;
            r) PATH_RC="$(readlink -f $OPTARG)";;
            m) MINUTES="$OPTARG";;
        esac
    done
    shift $((OPTIND-1))
    ARGS="${ARGS} $1 "
    shift
done


python3 ${PATH_TASKPROC} --path_sbatch ${PATH_SBATCH} \
                              -j ${JOBS} \
                              --path_img ${PATH_IMG} \
                              --path_sh ${PATH_SH} \
                              --path_log ${PATH_LOG} \
                              --path_log_dir ${PATH_LOG_DIR} \
                              --path_cmds ${PATH_CMDS} \
                              --path_cmd_outputs ${PATH_CMD_OUTPUTS} \
                              --path_rc ${PATH_RC} \
                              --minutes ${MINUTES} \
                              $ARGS


