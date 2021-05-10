#!/bin/bash
node_task_processor.sbatch.sh \
    --job 1 \
    --job_id 7449101 \
    --path_img ../geoflood_docker_tacc.sif \
    --path_sh node_task_processor.sh \
    --path_log geoflood_singularity.log \
    --path_cmds workflow_commands-geoflood_singularity.sh \
    --path_cmd_outputs workflow_outputs-geoflood_singularity.txt \
    --path_rc workflow_configuration-geoflood_singularity.sh \
    --queue development \
    --start_time $(date -u +%s) \
    NOAA-10m-Final_flowlines-Colorado-120903010605
