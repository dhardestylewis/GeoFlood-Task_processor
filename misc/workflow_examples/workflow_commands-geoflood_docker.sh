eval "$(conda shell.bash hook)"
conda activate geoflood
python3 Tools/GeoNet/pygeonet_configure.py -dir $(pwd) -p TX-Counties-Travis-120702050202 -n Elevation --no_chunk --channel_type 0
python3 Tools/GeoNet/pygeonet_prepare.py
python3 Tools/GeoNet/pygeonet_slope_curvature.py
python3 Tools/GeoNet/pygeonet_nonlinear_filter.py
python3 Tools/GeoNet/pygeonet_grass_py3.py 
python3 Tools/GeoNet/pygeonet_skeleton_definition.py
python3 Tools/GeoNet/pygeonet_flow_accumulation.py
python3 Tools/GeoNet/pygeonet_fast_marching.py
python3 Tools/GeoNet/pygeonet_channel_head_definition.py
python3 Tools/GeoFlood/Network_Node_Reading.py 
python3 Tools/GeoFlood/Relative_Height_Estimation.py 
python3 Tools/GeoFlood/Network_Extraction.py 
mpiexec -n 7 pitremove -z GeoInputs/GIS/TX-Counties-Travis-120702050202/Elevation.tif -fel GeoOutputs/GIS/TX-Counties-Travis-120702050202/Elevation_fel.tif 
mpiexec -n 7 dinfflowdir -ang GeoOutputs/GIS/TX-Counties-Travis-120702050202/Elevation_ang.tif -fel GeoOutputs/GIS/TX-Counties-Travis-120702050202/Elevation_fel.tif -slp GeoOutputs/GIS/TX-Counties-Travis-120702050202/Elevation_slp.tif
mpiexec -n 7 areadinf -ang GeoOutputs/GIS/TX-Counties-Travis-120702050202/Elevation_ang.tif -sca GeoOutputs/GIS/TX-Counties-Travis-120702050202/Elevation_sca.tif
mpiexec -n 7 dinfdistdown -ang GeoOutputs/GIS/TX-Counties-Travis-120702050202/Elevation_ang.tif -fel GeoOutputs/GIS/TX-Counties-Travis-120702050202/Elevation_fel.tif -slp GeoOutputs/GIS/TX-Counties-Travis-120702050202/Elevation_slp.tif -src GeoOutputs/GIS/TX-Counties-Travis-120702050202/Elevation_path.tif -dd GeoOutputs/GIS/TX-Counties-Travis-120702050202/Elevation_hand.tif -m ave v
python3 Tools/GeoFlood/Streamline_Segmentation.py 
python3 Tools/GeoFlood/Grass_Delineation_py3.py 
python3 Tools/GeoFlood/River_Attribute_Estimation.py 
python3 Tools/GeoFlood/Network_Mapping.py 
mpiexec -n 7 catchhydrogeo -hand GeoOutputs/GIS/TX-Counties-Travis-120702050202/Elevation_hand.tif -catch GeoOutputs/GIS/TX-Counties-Travis-120702050202/Elevation_segmentCatchment.tif -catchlist GeoOutputs/Hydraulics/TX-Counties-Travis-120702050202/Elevation_River_Attribute.txt -slp GeoOutputs/GIS/TX-Counties-Travis-120702050202/Elevation_slp.tif -h GeoInputs/Hydraulics/TX-Counties-Travis-120702050202/stage.txt -table GeoOutputs/Hydraulics/TX-Counties-Travis-120702050202/hydroprop-basetable.csv
python3 Tools/GeoFlood/Hydraulic_Property_Postprocess.py 
python3 Tools/GeoFlood/Forecast_Table.py GeoInputs/NWM/TX-Counties-Travis-120702050202/analysis_assim/20200713/nwm.t00z.analysis_assim.channel_rt.tm00.conus.nc 
mpiexec -n 7 /opt/TauDEM.git/bin/inunmap -hand GeoOutputs/GIS/TX-Counties-Travis-120702050202/Elevation_hand.tif -catch GeoOutputs/GIS/TX-Counties-Travis-120702050202/Elevation_segmentCatchment.tif -forecast GeoOutputs/NWM/TX-Counties-Travis-120702050202/nwm.t00z.analysis_assim.channel_rt.tm00.conus.nc -mapfile GeoOutputs/Inundation/TX-Counties-Travis-120702050202/Elevation_NWM_inunmap.tif
