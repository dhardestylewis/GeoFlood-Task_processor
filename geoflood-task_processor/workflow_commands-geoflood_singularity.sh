CONDA_INITIALIZE 'geoflood'
singularity run ${SCRATCH}/geoflood_docker_tacc.sif ${PATH_TASK_PROC}/ibrun_wrapper.sh --environment geoflood --command "python3 ${PATH_GEOFLOOD}/GeoNet/pygeonet_configure.py -dir ${WORKING_DIRECTORY} -p ${PROJECT} -n ${PROJECT} --no_chunk --channel_type 0" &
singularity run ${SCRATCH}/geoflood_docker_tacc.sif ${PATH_TASK_PROC}/ibrun_wrapper.sh --environment geoflood --command "python3 ${PATH_GEOFLOOD}/GeoNet/pygeonet_prepare.py" &
singularity run ${SCRATCH}/geoflood_docker_tacc.sif ${PATH_TASK_PROC}/ibrun_wrapper.sh --environment geoflood --command "python3 ${PATH_GEOFLOOD}/GeoNet/pygeonet_nonlinear_filter.py" &
singularity run ${SCRATCH}/geoflood_docker_tacc.sif ${PATH_TASK_PROC}/ibrun_wrapper.sh --environment geoflood --command "python3 ${PATH_GEOFLOOD}/GeoNet/pygeonet_slope_curvature.py" &
singularity run ${SCRATCH}/geoflood_docker_tacc.sif ${PATH_TASK_PROC}/ibrun_wrapper.sh --environment geoflood --command "python3 ${PATH_GEOFLOOD}/GeoNet/pygeonet_grass_py3.py" &
ibrun -np 67 singularity run ${SCRATCH}/geoflood_docker_tacc.sif ${PATH_TASK_PROC}/ibrun_wrapper.sh --environment geoflood --command "pitremove -z ${PATH_GEOINPUTS}/GIS/${PROJECT}/${PROJECT}.tif -fel ${PATH_GEOOUTPUTS}/GIS/${PROJECT}/${PROJECT}_fel.tif" &
gdal_translate -a_srs $(gdalsrsinfo -e ${PATH_GEOINPUTS}/GIS/${PROJECT}/${PROJECT}.tif | head -n2 | tail -n1) ${PATH_GEOOUTPUTS}/GIS/${PROJECT}/${PROJECT}_fel.tif ${PATH_GEOOUTPUTS}/GIS/${PROJECT}/${PROJECT}_fel_srs.tif &
mv ${PATH_GEOOUTPUTS}/GIS/${PROJECT}/${PROJECT}_fel_srs.tif ${PATH_GEOOUTPUTS}/GIS/${PROJECT}/${PROJECT}_fel.tif &
ibrun -np 67 singularity run ${SCRATCH}/geoflood_docker_tacc.sif ${PATH_TASK_PROC}/ibrun_wrapper.sh --environment geoflood --command "dinfflowdir -ang ${PATH_GEOOUTPUTS}/GIS/${PROJECT}/${PROJECT}_ang.tif -fel ${PATH_GEOOUTPUTS}/GIS/${PROJECT}/${PROJECT}_fel.tif -slp ${PATH_GEOOUTPUTS}/GIS/${PROJECT}/${PROJECT}_slp.tif" &
gdal_translate -a_srs $(gdalsrsinfo -e ${PATH_GEOINPUTS}/GIS/${PROJECT}/${PROJECT}.tif | head -n2 | tail -n1) ${PATH_GEOOUTPUTS}/GIS/${PROJECT}/${PROJECT}_ang.tif ${PATH_GEOOUTPUTS}/GIS/${PROJECT}/${PROJECT}_ang_srs.tif &
mv ${PATH_GEOOUTPUTS}/GIS/${PROJECT}/${PROJECT}_ang_srs.tif ${PATH_GEOOUTPUTS}/GIS/${PROJECT}/${PROJECT}_ang.tif &
gdal_translate -a_srs $(gdalsrsinfo -e ${PATH_GEOINPUTS}/GIS/${PROJECT}/${PROJECT}.tif | head -n2 | tail -n1) ${PATH_GEOOUTPUTS}/GIS/${PROJECT}/${PROJECT}_slp.tif ${PATH_GEOOUTPUTS}/GIS/${PROJECT}/${PROJECT}_slp_srs.tif &
mv ${PATH_GEOOUTPUTS}/GIS/${PROJECT}/${PROJECT}_slp_srs.tif ${PATH_GEOOUTPUTS}/GIS/${PROJECT}/${PROJECT}_slp.tif &
ibrun -np 67 singularity run ${SCRATCH}/geoflood_docker_tacc.sif ${PATH_TASK_PROC}/ibrun_wrapper.sh --environment geoflood --command "areadinf -ang ${PATH_GEOOUTPUTS}/GIS/${PROJECT}/${PROJECT}_ang.tif -sca ${PATH_GEOOUTPUTS}/GIS/${PROJECT}/${PROJECT}_sca.tif" &
gdal_translate -a_srs $(gdalsrsinfo -e ${PATH_GEOINPUTS}/GIS/${PROJECT}/${PROJECT}.tif | head -n2 | tail -n1) ${PATH_GEOOUTPUTS}/GIS/${PROJECT}/${PROJECT}_sca.tif ${PATH_GEOOUTPUTS}/GIS/${PROJECT}/${PROJECT}_sca_srs.tif &
mv ${PATH_GEOOUTPUTS}/GIS/${PROJECT}/${PROJECT}_sca_srs.tif ${PATH_GEOOUTPUTS}/GIS/${PROJECT}/${PROJECT}_sca.tif &
singularity run ${SCRATCH}/geoflood_docker_tacc.sif ${PATH_TASK_PROC}/ibrun_wrapper.sh --environment geoflood --command "python3 ${PATH_GEOFLOOD}/GeoNet/pygeonet_shapefile2binaryraster_pathburn.py ${WORKING_DIRECTORY} ${PROJECT} ${PROJECT}" &
ibrun -np 67 singularity run ${SCRATCH}/geoflood_docker_tacc.sif ${PATH_TASK_PROC}/ibrun_wrapper.sh --environment geoflood --command "dinfdistdown -ang ${PATH_GEOOUTPUTS}/GIS/${PROJECT}/${PROJECT}_ang.tif -fel ${PATH_GEOOUTPUTS}/GIS/${PROJECT}/${PROJECT}_fel.tif -slp ${PATH_GEOOUTPUTS}/GIS/${PROJECT}/${PROJECT}_slp.tif -src ${PATH_GEOOUTPUTS}/GIS/${PROJECT}/${PROJECT}_path.tif -dd ${PATH_GEOOUTPUTS}/GIS/${PROJECT}/${PROJECT}_hand.tif -m ave v" &
gdal_translate -a_srs $(gdalsrsinfo -e ${PATH_GEOINPUTS}/GIS/${PROJECT}/${PROJECT}.tif | head -n2 | tail -n1) ${PATH_GEOOUTPUTS}/GIS/${PROJECT}/${PROJECT}_hand.tif ${PATH_GEOOUTPUTS}/GIS/${PROJECT}/${PROJECT}_hand_srs.tif &
mv ${PATH_GEOOUTPUTS}/GIS/${PROJECT}/${PROJECT}_hand_srs.tif ${PATH_GEOOUTPUTS}/GIS/${PROJECT}/${PROJECT}_hand.tif &
singularity run ${SCRATCH}/geoflood_docker_tacc.sif ${PATH_TASK_PROC}/ibrun_wrapper.sh --environment geoflood --command "python3 ${PATH_GEOFLOOD}/GeoFlood/Streamline_Segmentation.py" &
singularity run ${SCRATCH}/geoflood_docker_tacc.sif ${PATH_TASK_PROC}/ibrun_wrapper.sh --environment geoflood --command "python3 ${PATH_GEOFLOOD}/GeoFlood/Grass_Delineation_py3.py" &
singularity run ${SCRATCH}/geoflood_docker_tacc.sif ${PATH_TASK_PROC}/ibrun_wrapper.sh --environment geoflood --command "python3 ${PATH_GEOFLOOD}/GeoFlood/River_Attribute_Estimation.py" &
singularity run ${SCRATCH}/geoflood_docker_tacc.sif ${PATH_TASK_PROC}/ibrun_wrapper.sh --environment geoflood --command "python3 ${PATH_GEOFLOOD}/GeoFlood/Network_Mapping.py" &
ibrun -np 67 singularity run ${SCRATCH}/geoflood_docker_tacc.sif ${PATH_TASK_PROC}/ibrun_wrapper.sh --environment geoflood --command "catchhydrogeo -hand ${PATH_GEOOUTPUTS}/GIS/${PROJECT}/${PROJECT}_hand.tif -catch ${PATH_GEOOUTPUTS}/GIS/${PROJECT}/${PROJECT}_segmentCatchment.tif -catchlist ${PATH_GEOOUTPUTS}/Hydraulics/${PROJECT}/${PROJECT}_River_Attribute.txt -slp ${PATH_GEOOUTPUTS}/GIS/${PROJECT}/${PROJECT}_slp.tif -h ${PATH_GEOINPUTS}/Hydraulics/${PROJECT}/stage.txt -table ${PATH_GEOOUTPUTS}/Hydraulics/${PROJECT}/hydroprop-basetable.csv" &
singularity run ${SCRATCH}/geoflood_docker_tacc.sif ${PATH_TASK_PROC}/ibrun_wrapper.sh --environment geoflood --command "python3 ${PATH_GEOFLOOD}/GeoFlood/Hydraulic_Property_Postprocess.py" &
singularity run ${SCRATCH}/geoflood_docker_tacc.sif ${PATH_TASK_PROC}/ibrun_wrapper.sh --environment geoflood --command "python3 ${PATH_GEOFLOOD}/GeoFlood/Forecast_Table.py ${PATH_GEOINPUTS}/NWM/${PROJECT}/nwm.t00z.analysis_assim.channel_rt.tm00.conus.nc" &
ibrun -np 67 singularity run ${SCRATCH}/geoflood_docker_tacc.sif ${PATH_TASK_PROC}/ibrun_wrapper.sh --environment geoflood --command "inunmap -hand ${PATH_GEOOUTPUTS}/GIS/${PROJECT}/${PROJECT}_hand.tif -catch ${PATH_GEOOUTPUTS}/GIS/${PROJECT}/${PROJECT}_segmentCatchment.tif -forecast ${PATH_GEOOUTPUTS}/NWM/${PROJECT}/nwm.t00z.analysis_assim.channel_rt.tm00.conus.nc -mapfile ${PATH_GEOOUTPUTS}/Inundation/${PROJECT}/${PROJECT}_NWM_inunmap.tif" &
gdal_translate -a_srs $(gdalsrsinfo -e ${PATH_GEOINPUTS}/GIS/${PROJECT}/${PROJECT}.tif | head -n2 | tail -n1) ${PATH_GEOOUTPUTS}/Inundation/${PROJECT}/${PROJECT}_NWM_inunmap.tif ${PATH_GEOOUTPUTS}/Inundation/${PROJECT}/${PROJECT}_NWM_inunmap_srs.tif &
mv ${PATH_GEOOUTPUTS}/Inundation/${PROJECT}/${PROJECT}_NWM_inunmap_srs.tif ${PATH_GEOOUTPUTS}/Inundation/${PROJECT}/${PROJECT}_NWM_inunmap.tif &
: &
CONDA_DEACTIVATE
