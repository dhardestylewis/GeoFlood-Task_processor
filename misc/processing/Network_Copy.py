from pathlib import Path
import pandas as pd
import os
from shutil import copyfile

flowlines = list(Path('./GeoInputs/GIS').rglob('Flowline.shp'))
copy_gdf = pd.DataFrame({'flowline_fns':flowlines})
copy_gdf['elevation_fns'] = copy_gdf['flowline_fns'].apply(
    lambda fn: list(Path(os.path.dirname(fn)).rglob('*.tif'))
)
copy_gdf = copy_gdf[copy_gdf['elevation_fns'].apply(lambda fn: not not fn)]
copy_gdf['elevation_fns'] = copy_gdf['elevation_fns'].apply(lambda fn: fn[0])
copy_gdf['channelnetwork_fns'] = copy_gdf['elevation_fns'].apply(
    lambda fn: Path(os.path.join(
        '.',
        'GeoOutputs',
        'GIS',
        os.path.splitext(os.path.basename(fn))[0],
        os.path.splitext(os.path.basename(fn))[0]+'_channelNetwork.shp'
    ))
)
copy_gdf['flowline_aux_fns'] = copy_gdf['flowline_fns'].apply(
    lambda fn: list(Path(os.path.dirname(fn)).glob(
        os.path.splitext(os.path.basename(fn))[0]+'.*'
    ))
)
copy_gdf['channelnetwork_aux_fns'] = copy_gdf.apply(
    lambda gdf: [Path(os.path.join(
        os.path.dirname(gdf['channelnetwork_fns']),
        os.path.splitext(os.path.basename(gdf['channelnetwork_fns']))[0] +
            os.path.splitext(ext)[1]
    )) for ext in gdf['flowline_aux_fns']],
    axis = 1
)
copy_gdf.apply(lambda gdf: [
    copyfile(src,dst)
    for src,dst
    in zip(gdf['flowline_aux_fns'],gdf['channelnetwork_aux_fns'])
],axis=1)
