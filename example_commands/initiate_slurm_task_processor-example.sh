#!/bin/bash
initiate_slurm_task_processor.sh \
    --path_taskproc slurm_task_processor.py \
    -j 1 \
    --path_sbatch node_task_processor.sbatch.sh \
    --path_cmds workflow_commands-geoflood_singularity.sh \
    --path_cmd_outputs workflow_outputs-geoflood_singularity.txt \
    --path_log_dir ../logs \
    --path_log geoflood_singularity.log \
    --path_rc workflow_configuration-geoflood_singularity.sh \
    --path_img ../geoflood_docker_tacc.sif \
    --path_sh node_task_processor.sh \
    --minutes 15 \
    $(echo $(cat tasks-NOAA_Seven_Counties.txt))
