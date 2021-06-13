# GeoFlood task processor
This task processor schedules each step of the GeoFlood workflow on a SLURM cluster. Key features include:
* Logs including:
    * Step of GeoFlood workflow
    * Elapsed time per step (including task processor overhead)
    * SLURM queue per step
    * Whether a step takes longer than the longest available queue
    * Success/failure of a step
    * Exit code of step
* Automatic rescheduling the workflow with a new SLURM job if workflow runs out of time in its queue
    * Automatically bumps the workflow up to the next longest available queue
    * Restarts workflow from the step that was cut short
* Step-by-step output detection to skip already completed steps of the workflow

Future features include:
* Remote file system download and upload to minimize local disk usage
* User-defined queue limit

While this task processor has been designed with the needs of the GeoFlood workflow in mind, other workflows can be substituted.
Other workflow examples may be found in `misc/workflow_examples`.
For another application of this task processor to an extensive workflow, see my [HAND-TauDEM GitHub repository](https://github.com/dhardestylewis/HAND-TauDEM).

This task processor is designed to be used in conjunction with [GeoFlood](https://github.com/passaH2O/GeoFlood).
Currently, it is necessary to use [my fork of GeoFlood](https://github.com/dhardestylewis/GeoFlood).
Differences between this fork and the main GeoFlood repository will be merged soon.

## Main shell script
All of the main scripts may be found in `geoflood_task_processor/`.
Once the environment is set up (see below), the task processor may be initiated by executing the following command on a scheduler node of a SLURM cluster:
```
initiate_slurm_task_processor.sh \
    --path_taskproc slurm_task_processor.py \
    -j 1 \
    --path_sbatch node_task_processor.sbatch.sh \
    --path_cmds workflow_commands-geoflood-singularity.sh \
    --path_log geoflood_singularity.log \
    --path_rc workflow_configuration-geoflood_singularity.sh \
    --path_img ../geoflood_docker_tacc.sif \
    --path_sh node_task_processor.sh \
    --minutes 15 \
    $(echo $(cat tasks.txt))
```

## Software dependencies
* [GeoFlood](https://github.com/dhardestylewis/GeoFlood)
* [Conda](https://conda.io/projects/conda/en/latest/user-guide/install/linux.html)
* [Singularity](https://sylabs.io/guides/3.0/user-guide/installation.html) or [Docker](https://docs.docker.com/engine/install/centos/)

## Setting up the environment
Download GeoFlood:
```
git clone https://github.com/dhardestylewis/GeoFlood.git
```
Install the GeoFlood Conda environment
```
conda install -f environments/environment-geoflood.yml
```
If necessary, prepare DEMs, catchment and flowline vector images, roughness tables. The [DEM2basin preprocessing script](https://github.com/dhardestylewis/DEM2basin) is available for this, if needed.
```
python3 geoflood-preprocessing-1m-mp.py \
    --shapefile study_area_polygon.shp \
    --huc12 WBD-HUC12s.shp \
    --nhd NHD_catchments_and_flowlines.gdb/ \
    --raster TNRIS-LIDAR-Datasets/ \
    --availability TNRIS-LIDAR-Dataset_availability.shp \
    --directory HUC12-DEM_outputs/ \
    --restart geoflood-preprocessing-study_area.pickle
```
Create a `stage.txt` file
```
for i in $(seq 0.0 0.1 20.0); do
    echo $i >> stage.txt;
done
```
Download the correct NWM NetCDF file for your flood event.

Organize the DEMs, catchment GIS, flowline GIS, roughness tables, stage tables, and NWM NetCDF files into the GeoFlood file hierarchy as described in the [GeoFlood GitHub repository](https://github.com/dhardestylewis/GeoFlood).

Download the [GeoFlood HPC Singularity image](https://hub.docker.com/r/dhardestylewis/geoflood_docker):
```
singularity pull docker://geoflood_docker:tacc
```

Modify `geoflood_task_processor/workflow_configuration-geoflood_singularity.sh` to reflect your particular file locations.

Draft a `tasks.txt` file that contains the name of each GeoFlood project on each line, for example:
```
HUC1
HUC2
HUC3
```

Now run `initiate_slurm_task_processor.sh`:
```
initiate_slurm_task_processor.sh \
    --path_taskproc slurm_task_processor.py \
    -j 1 \
    --path_sbatch node_task_processor.sbatch.sh \
    --path_cmds workflow_commands-geoflood-singularity.sh \
    --path_log geoflood_singularity.log \
    --path_rc workflow_configuration-geoflood_singularity.sh \
    --path_img ../geoflood_docker_tacc.sif \
    --path_sh node_task_processor.sh \
    --minutes 15 \
    $(echo $(cat tasks.txt))
```

## Description of log files
The log files are flat CSV tables, with the following columns:
* `index`
    * the unique index is generated by concatenating the `start_time` and the `pid`
* `pid`
    * the process id of the executed step of the workflow
* `start_time`
    * the start time of the executed step of the workflow in seconds since the 1970 epoch
* `job_id`
    * the SLURM job ID
* `queue`
    * the selected SLURM queue
* `elapsed_time`
    * time elapsed between the task processor's initiation and the start time of the executed step of the workflow
* `error_long_queue_timeout`
    * error flag if this step fails due to not enough time available on the longest queue
* `complete`
    * flag if the step finishes successfully
* `last_cmd`
    * the step of the workflow executed
* `exit_code`
    * exit code of the step of the workflow

## Depictions

Overview of this task processor
![Depiction of this task processor](https://github.com/dhardestylewis/GeoFlood-Task_processor/blob/main/images/GeoFlood-Task_processor-quality.jpg)

## Workflow example for NOAA counties at 10m

Example workflow used with this task processor
![Depiction of GeoFlood workflow](https://github.com/dhardestylewis/GeoFlood-Task_processor/blob/main/images/GeoFlood_Singularity-Workflow-quality.jpg)

### Depiction of HANDs produced from this task processor

![10m HAND results for some counties](https://github.com/dhardestylewis/GeoFlood-Task_processor/blob/main/images/HANDs_depicted.png)

### Timings obtained from the logs of an example run of this workflow

* All units _in seconds_

GeoNet
![pygeonet_grass_py3.py](https://github.com/dhardestylewis/GeoFlood-Task_processor/blob/main/images/NOAA-10m-Final_flowlines-pygeonet_grass_py3.py.png)

TauDEM
![dinfdistdown](https://github.com/dhardestylewis/GeoFlood-Task_processor/blob/main/images/NOAA-10m-Final_flowlines-dinfdistdown.png)

GeoFlood
![Streamline_Segmentation.py](https://github.com/dhardestylewis/GeoFlood-Task_processor/blob/main/images/NOAA-10m-Final_flowlines-Streamline_Segmentation.py.png)

### Cumulative timing plot

This plot depicts cumulative timings _in seconds_ for each step of the workflow.
![Cumulative timings](https://github.com/dhardestylewis/GeoFlood-Task_processor/blob/main/images/NOAA-10m-Final_flowlines-Cumulative_command_timings.png)

### Notes about these processed 10m DEMs
* All of the DEMS are reprojected to [WGS 84 / UTM 14N](https://epsg.io/32614), even if the HUC12 is outside of UTM 14.
### Where to find them
The DEMs are located on [Stampede2](https://www.tacc.utexas.edu/systems/stampede2) at `/scratch/projects/tnris/dhl-flood-modelling/GeoFlood/GeoFlood-Task_processor`.
### If you run into trouble
Please [submit a ticket](https://portal.tacc.utexas.edu/tacc-consulting) if you have trouble accessing this data. You may also contact me directly at [@dhardestylewis](https://github.com/dhardestylewis) or <dhl@tacc.utexas.edu>


