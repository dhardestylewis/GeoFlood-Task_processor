#!/bin/bash

### Load functions from Anaconda or TauDEM
source $HOME/miniconda3/etc/profile.d/conda.sh
source $HOME/.taudemrc

### Activate environments, GGenv is Python 3.7, GGenv-py2 is Python 2.7
conda activate GGenv
# conda activate GGenv-py2

### Set NFIE directory
# NFIEDIR=/work/00837/tg458936/stampede2

### Set TauDEM directory
TAUGEO=/work/00837/tg458936/stampede2/taudem/TauDEM-CatchHydroGeo

### Configure work directory
HomeDir='/work/07045/rschomp/stampede2/GeoFlood'

### Configure scratch directory
ScratchDir='/scratch/07045/rschomp/GeoFlood'
# ScratchDirOutputs='/scratch/07045/rschomp/GeoFlood/Outputs'

### Configure inundation map directories
InunMap_Title='ABSOLUTE_WORST_CASE'
InunMap_ncFile='nwm.t_AUG_z.analysis_assim.channel_rt.tm_Absolute_MAX.conus.nc'
# InunMap_Name='absworsttest'

### Set positional parameters
projectName=$1 
DEM_name=$2
# ScratchDirOutputs=$3 # TauDEM InunMap 
burn_option=0

### LOCAL: Fix locale setting warning
#	 Solves => 
# 		perl: warning: Falling back to the standard locale ("C").
# 		perl: warning: Setting locale failed.
# 		perl: warning: Please check that your locale settings:
#			LANGUAGE = (unset),
#			LC_ALL = (unset),
#			LANG = "C.UTF-8"
#    		are supported and installed on your system.
# export LANGUAGE=en_US.UTF-8
# export LANG=en_US.UTF-8
# export LC_ALL=en_US.UTF-8

### GRASS: Add Dr. Arctur's GRASS GIS 7.6 installation to $PATH
# 	Solves =>
# 		ERROR: --config: grass76: command not found
# 		ERROR: Cannot find GRASS GIS 7 start script (['grass76', '--config', 'path'])
export PATH=/home1/02044/arcturdk/local/bin/:$PATH

### GRASS: Fix shared library error by assigning GDAL_DATA to own miniconda3 library path
# 	Solves =>
# 		g.proj: error while loading shared libraries: 
# 		libgdal.so.20: cannot open shared object file: No such file or directory
export GDAL_DATA=/home1/07045/rschomp/miniconda3/pkgs/libgdal-2.3.3-h2e7e64b_0/share/gdal/:$GDAL_DATA

### TAUDEM: Add TauDEM functions to $PATH
#       Solves =>
#               TACC:  Starting parallel tasks...
#               match_arg (../../utils/args/args.c:254): unrecognized argument {TauDEM function, i.e. -z in pitremove}
#               HYDU_parse_array (../../utils/args/args.c:269): argument matching returned error
#               parse_args (./../utils/args/args.c:4770): error parsing input array
#               HYD_uii_mpx_get_parameters (../../ui.mpich/utils.c:5106): unable to parse user arguments
export PATH=/work/00837/tg458936/stampede2/taudem/TauDEM-CatchHydroGeo:$PATH

### TAUDEM: InunMap HDF5 Error Testing
# export LD_LIBRARY_PATH=/usr/lib:$LD_LIBRARY_PATH
# export LD_LIBRARY_PATH=/home1/07045/rschomp/miniconda3/pkgs/libgdal-2.3.3-h2e7e64b_0/lib/libgdal.so.20:$LD_LIBRARY_PATH

### Add missing libraries for GRASS GIS 7.6
module load RstatsPackages/3.5.1 # Solved libgdal.so.20 errors
module load netcdf/4.6.2 # Solved HDF5 errors for catchhydrogeo

# ---

### Run Python Scripts

# python $HomeDir/Tools/GeoNet_Batch/pygeonet_nonlinear_filter.py $projectName $DEM_name

# python $HomeDir/Tools/GeoNet_Batch/pygeonet_slope_curvature.py $projectName $DEM_name

# python $HomeDir/Tools/GeoNet_Batch/pygeonet_grass.py $projectName $DEM_name

# python $HomeDir/Tools/GeoNet_Batch/pygeonet_skeleton_definition.py $projectName $DEM_name

# python $HomeDir/Tools/GeoNet_Batch/pygeonet_shapefile2binaryraster_pathburn.py $ScratchDir $projectName $DEM_name

# python $HomeDir/Tools/GeoFlood_Batch/Streamline_Segmentation.py $ScratchDir $projectName $DEM_name

# python $HomeDir/Tools/GeoFlood_Batch/River_Attribute_Estimation.py $ScratchDir $projectName $DEM_name

# python $HomeDir/Tools/GeoFlood_Batch/Network_Mapping.py $ScratchDir $projectName $DEM_name

# python $HomeDir/Tools/GeoFlood_Batch/Hydraulic_Property_Postprocess.py $ScratchDir $projectName $DEM_name

# python $HomeDir/Tools/GeoFlood_Batch/Forecast_Table.py $ScratchDir $projectName $DEM_name $InunMap_Title $InunMap_ncFile

# ---

### Run TauDEM scripts

# ibrun pitremove -z ${ScratchDir}/Inputs/GIS/${projectName}/${DEM_name}.tif -fel ${ScratchDir}/Outputs/GIS/${projectName}/${DEM_name}_fel.tif

# ibrun dinfflowdir -fel ${ScratchDir}/Outputs/GIS/${projectName}/${DEM_name}_fel.tif -ang ${ScratchDir}/Outputs/GIS/${projectName}/${DEM_name}_ang.tif -slp ${ScratchDir}/Outputs/GIS/${projectName}/${DEM_name}_slp.tif

# ibrun dinfdistdown -ang ${ScratchDir}/Outputs/GIS/${projectName}/${DEM_name}_ang.tif -fel ${ScratchDir}/Outputs/GIS/${projectName}/${DEM_name}_fel.tif -slp ${ScratchDir}/Outputs/GIS/${projectName}/${DEM_name}_slp.tif -src ${ScratchDir}/Outputs/GIS/${projectName}/${DEM_name}_path.tif -dd ${ScratchDir}/Outputs/GIS/${projectName}/${DEM_name}_hand.tif -m ave v

# ibrun catchhydrogeo -hand ${ScratchDir}/Outputs/GIS/${projectName}/${DEM_name}_hand.tif -catch ${ScratchDir}/Outputs/GIS/${projectName}/${DEM_name}_segmentCatchment.tif -catchlist ${ScratchDir}/Outputs/Hydraulics/${projectName}/${DEM_name}_River_Attribute.txt -slp ${ScratchDir}/Outputs/GIS/${projectName}/${DEM_name}_slp.tif -h ${ScratchDir}/Inputs/Hydraulics/stage.txt -table ${ScratchDir}/Outputs/Hydraulics/${projectName}/hydroprop-basetable.csv

inunmap -hand ${ScratchDirOutputs}/GIS/${projectName}/${DEM_name}_hand.tif -catch ${ScratchDirOutputs}/GIS/${projectName}/${DEM_name}_segmentCatchment.tif -forecast ${ScratchDirOutputs}/NWM/${InunMap_Title}/${projectName}/${InunMap_ncFile} -mapfile ${ScratchDirOutputs}/Inundation/${InunMap_Title}/${projectName}/${DEM_name}_${InunMap_Name}.tif

