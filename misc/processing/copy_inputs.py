import os
from shutil import copyfile
from pathlib import Path
import pandas as pd
import geopandas as gpd

hucs = list(Path(os.path.join(
    os.sep,
    'scratch',
    '04950',
    'dhl',
    'GeoFlood',
    'GeoFlood',
    'Shapes'
)).rglob('*_HUCs.shp'))
src = os.path.join(
    os.sep,
    'scratch',
    '04950',
    'dhl',
    'GeoFlood',
    'GeoFlood-preprocessing',
    'DEM2basin-10m',
    'Seven_counties_simple'
)
src_alt = os.path.join(
    os.sep,
    'scratch',
    '07043',
    'ac1824',
    'GeoFlood',
    'FINAL_FLOWLINES'
)
dst = os.path.join(
    os.sep,
    'scratch',
    '04950',
    'dhl',
    'GeoFlood',
    'GeoFlood'
)

gdfs = [gpd.read_file(huc) for huc in hucs]
[gdf.reset_index(inplace=True) for gdf in gdfs]
[gdf.rename(columns={'index':'FID'},inplace=True) for gdf in gdfs]
[gdf.to_crs('EPSG:4269',inplace=True) for gdf in gdfs]
for gdf,huc in zip(gdfs,hucs):
    gdf['county'] = huc.parts[-2]

gdf = gpd.GeoDataFrame(pd.concat(gdfs,ignore_index=True),crs=gdfs[0].crs)
gdf['dems_src'] = gdf.apply(lambda gdf: os.path.join(
    src,
    'TX-Counties-Seven_NOAA-' + gdf['HUC_12'],
    'Elevation.tif'
), axis=1)
gdf['roughs_src'] = gdf.apply(lambda gdf: os.path.join(
    src,
    'TX-Counties-Seven_NOAA-' + gdf['HUC_12'],
    'Roughness.csv'
), axis=1)
gdf['catchs_src'] = gdf.apply(lambda gdf: os.path.join(
    src,
    'TX-Counties-Seven_NOAA-' + gdf['HUC_12'],
    'Catchments.shp'
), axis=1)
gdf['catchs_aux_src'] = gdf.apply(
    lambda gdf: list(Path(os.path.join(
        src,
        'TX-Counties-Seven_NOAA-' + gdf['HUC_12']
    )).rglob('Catchments.*')),
    axis = 1
)
gdf['flows_src'] = gdf.apply(lambda gdf: os.path.join(
    src_alt,
    gdf['county'],
    gdf['county'] + '_' + str(gdf['FID']) + '_1m_channelNetwork.shp'
), axis=1)
gdf['flows_aux_src'] = gdf.apply(
    lambda gdf: list(Path(os.path.join(src_alt,gdf['county'])).rglob(
        gdf['county'] +
        '_' +
        str(gdf['FID']) +
        '_1m_channelNetwork.*'
    )),
    axis=1
)
gdf['stages_src'] = gdf.apply(lambda gdf: os.path.join(
    dst,
    'stage.txt'
), axis=1)
gdf['nwms_src'] = gdf.apply(lambda gdf: os.path.join(
    dst,
    'nwm.t00z.analysis_assim.channel_rt.tm00.conus.nc'
), axis=1)

gdf['dems_dst'] = gdf.apply(lambda gdf: os.path.join(
    dst,
    'GeoInputs',
    'GIS',
    'NOAA-10m-Final_flowlines-' + gdf['county'] + '-' + gdf['HUC_12'],
    'NOAA-10m-Final_flowlines-' + gdf['county'] + '-' + gdf['HUC_12'] + '.tif'
), axis=1)
gdf['catchs_dst'] = gdf.apply(lambda gdf: os.path.join(
    dst,
    'GeoInputs',
    'GIS',
    'NOAA-10m-Final_flowlines-' + gdf['county'] + '-' + gdf['HUC_12'],
    'Catchment.shp'
), axis=1)
gdf['flows_dst'] = gdf.apply(lambda gdf: os.path.join(
    dst,
    'GeoInputs',
    'GIS',
    'NOAA-10m-Final_flowlines-' + gdf['county'] + '-' + gdf['HUC_12'],
    'Flowline.shp'
), axis=1)
gdf['flows_aux_dst'] = gdf.apply(lambda gdf: [os.path.join(
    dst,
    'GeoInputs',
    'GIS',
    'NOAA-10m-Final_flowlines-' + gdf['county'] + '-' + gdf['HUC_12'],
    'Flowline' + os.path.splitext(fn)[1]
) for fn in gdf['flows_aux_src']], axis=1)
gdf['catchs_aux_dst'] = gdf.apply(lambda gdf: [os.path.join(
    dst,
    'GeoInputs',
    'GIS',
    'NOAA-10m-Final_flowlines-' + gdf['county'] + '-' + gdf['HUC_12'],
    'Catchment' + os.path.splitext(fn)[1]
) for fn in gdf['catchs_aux_src']], axis=1)
gdf['roughs_dst'] = gdf.apply(lambda gdf: os.path.join(
    dst,
    'GeoInputs',
    'Hydraulics',
    'NOAA-10m-Final_flowlines-' + gdf['county'] + '-' + gdf['HUC_12'],
    'COMID_Roughness.csv'
), axis=1)
gdf['stages_dst'] = gdf.apply(lambda gdf: os.path.join(
    dst,
    'GeoInputs',
    'Hydraulics',
    'NOAA-10m-Final_flowlines-' + gdf['county'] + '-' + gdf['HUC_12'],
    'stage.txt'
), axis=1)
gdf['nwms_dst'] = gdf.apply(lambda gdf: os.path.join(
    dst,
    'GeoInputs',
    'NWM',
    'NOAA-10m-Final_flowlines-' + gdf['county'] + '-' + gdf['HUC_12'],
    'nwm.t00z.analysis_assim.channel_rt.tm00.conus.nc'
), axis=1)

gdf.apply(lambda gdf: [
    copyfile(src,dst)
    for src,dst
    in zip(gdf['catchs_aux_src'],gdf['catchs_aux_dst'])
], axis=1)
gdf.apply(lambda gdf: [
    copyfile(src,dst)
    for src,dst
    in zip(gdf['flows_aux_src'],gdf['flows_aux_dst'])
], axis=1)
gdf[gdf['dems_src'].apply(lambda path: os.path.exists(path))].apply(
    lambda gdf: copyfile(gdf['dems_src'],gdf['dems_dst']),
    axis = 1
)
gdf[gdf['roughs_src'].apply(lambda path: os.path.exists(path))].apply(
    lambda gdf: copyfile(gdf['roughs_src'],gdf['roughs_dst']),
    axis = 1
)
gdf[gdf['stages_src'].apply(lambda path: os.path.exists(path))].apply(
    lambda gdf: copyfile(gdf['stages_src'],gdf['stages_dst']),
    axis = 1
)
gdf[gdf['nwms_src'].apply(lambda path: os.path.exists(path))].apply(
    lambda gdf: copyfile(gdf['nwms_src'],gdf['nwms_dst']),
    axis = 1
)

