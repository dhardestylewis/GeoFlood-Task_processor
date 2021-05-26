#!/bin/bash
/shared/home/dhl/GeoFlood/GeoFlood-TaskProc-running/geoflood_task_processor/initiate_slurm_task_processor.sh \
    --path_taskproc /shared/home/dhl/GeoFlood/GeoFlood-TaskProc-running/geoflood_task_processor/slurm_task_processor.py \
    -j 1 \
    --path_sbatch /shared/home/dhl/GeoFlood/GeoFlood-TaskProc-running/geoflood_task_processor/node_task_processor.sbatch.sh \
    --path_cmds /shared/home/dhl/GeoFlood/GeoFlood-TaskProc-running/geoflood_task_processor/workflow_commands-geoflood_singularity.sh \
    --path_cmd_outputs /shared/home/dhl/GeoFlood/GeoFlood-TaskProc-running/geoflood_task_processor/workflow_outputs-geoflood_singularity.txt \
    --path_log_dir /shared/home/dhl/GeoFlood/logs \
    --path_log geoflood_singularity.log \
    --path_rc /shared/home/dhl/GeoFlood/GeoFlood-TaskProc-running/geoflood_task_processor/workflow_configuration-geoflood_singularity.sh \
    --path_sh /shared/home/dhl/GeoFlood/GeoFlood-TaskProc-running/geoflood_task_processor/node_task_processor.sh \
    --minutes 1 \
    --task_limit 14 \
    --remote_dir_inputs /shared/home/dhl/box/Harvey-Counties-GeoInputs \
    --local_dir_inputs /shared/home/dhl/GeoFlood/IO/GeoInputs \
    --remote_dir_outputs /shared/home/dhl/box/Harvey-Counties-GeoOutputs \
    --local_dir_outputs /shared/home/dhl/GeoFlood/IO/GeoOutputs \
    $(echo $(cat tasks-Harvey_Counties.txt))
