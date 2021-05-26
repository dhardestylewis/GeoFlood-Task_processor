from pathlib import Path
import geopandas as gpd
import rasterio
import pandas as pd
import os

hands = list(Path(os.path.join('GeoOutputs','GIS')).rglob('*_hand_srs.tif'))

hands = pd.DataFrame({'hands':hands})
hands['hand_rasters'] = hands['hands'].apply(lambda fn: rasterio.open(fn))
hands['hand_data'] = hands['hand_rasters'].apply(
    lambda raster: (raster.read(1)!=raster.nodata).max()
)
hands['catchments'] = hands['hands'].apply(lambda fn: Path(os.path.join(
    'GeoInputs',
    'GIS',
    fn.parts[2],
    'Catchment.shp'
)))
hands['catchment_gdfs'] = hands['catchments'].apply(
    lambda fn: gpd.read_file(fn)
)
hands['catchment_dissolved'] = hands['catchment_gdfs'].apply(
    lambda gdf: gdf.dissolve(by=['HUC12'])
)

catchments = gpd.GeoDataFrame(
    pd.concat(hands['catchment_dissolved'].to_list()),
    crs = hands.loc[0,'catchment_dissolved'].crs
)

catchments.to_file(
    'NOAA-7Counties-10m-1mFlowlines-HUC12s_proc.geojson',
    driver = 'GeoJSON'
)
