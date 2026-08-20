# Asset inventory

This inventory records the initial assets consolidated into this project. Repository paths are relative to this branding project.

## Organization and Hub

| Identity | Approved asset | Role | SVG status | Original source |
|---|---|---|---|---|
| Home Health Hub organization | `organization/avatar/approved/organization-avatar.png` and `.svg` | Organization avatar and the single Health Hub launcher icon | Native vector approved; original PNG retained | `.github/profile/avatar.png` |
| Health Hub | `healthhub/approved/home-health-hub.png` | Hub documentation and large UI image | Approved hybrid SVG preserves the raster exactly | `healthhub/docs/images/home-health-hub.png` |

## Daemons

| Product | Accent | Approved assets | SVG status |
|---|---|---|---|
| Etekcity scale | Coral-orange | Banner, application image, navigation icon | Hybrid SVGs preserve approved rasters |
| Etekcity blood pressure | Coral | Banner, application image, navigation icon | Hybrid SVGs preserve approved rasters |
| Trividia TRUE METRIX | Warm gold | Banner, application image, navigation icon | Hybrid SVGs preserve approved rasters |
| Viatom O2Ring | Oxygen blue with coral pulse | Banner, application image, navigation icon | Hybrid SVGs preserve approved rasters |
| Easy@Home BBT | Cycle plum | Banner, application image, navigation icon | Hybrid SVGs preserve approved rasters |
| Health thermometer | Coral infrared and temperature accent | Banner, application image, navigation icon | Hybrid SVGs preserve approved rasters |

Each product's approved files are under `daemons/<product>/approved/`. Generated SVG and PNG derivatives are under `exports/`.

## SVG classification

The approved organization avatar and monochrome mark are native vectors. Other initial SVGs generated from current PNG artwork remain **hybrid SVGs**: they retain the approved raster image inside an SVG container with the correct dimensions and view box. They provide consistent SVG delivery without falsely presenting an automatic trace as editable native vector artwork.

Do not redraw approved raster artwork merely to obtain a native vector. A native replacement requires a separate design decision and visual approval; failed proposals are working material, not repository history.
