#!/bin/bash
start_time=$(date -u +%s)
while read p; do
    $(pwd)/node_task_processor.sbatch.sh \
        --job 1 \
        --job_id 7710493 \
        --path_img ${SCRATCH}/geoflood_docker_tacc.sif \
        --path_sh $(pwd)/node_task_processor.sh \
        --path_log geoflood_singularity.log \
        --path_cmds $(pwd)/workflow_commands-geoflood_singularity.sh \
        --path_cmd_outputs $(pwd)/workflow_outputs-geoflood_singularity.txt \
        --path_rc $(pwd)/workflow_configuration-geoflood_singularity.sh \
        --queue normal \
        --start_time $start_time \
        "$p"
done < tasks-NOAA.txt
