# Asset inventory

This inventory records the initial assets consolidated into this project. Repository paths are relative to this branding project.

## Organization and Hub

| Identity | Approved asset | Role | SVG status | Original source |
|---|---|---|---|---|
| Home Health Hub organization | `organization/avatar/approved/organization-avatar.png` and `.svg` | Organization avatar and the single Health Hub launcher icon | Native vector approved; original PNG retained | `.github/profile/avatar.png` |
| Health Hub | `healthhub/approved/home-health-hub.png` | Hub documentation and large UI image | Approved hybrid SVG preserves the raster exactly; simplified redraw rejected | `healthhub/docs/images/home-health-hub.png` |

## Daemons

| Product | Accent | Approved assets | SVG status |
|---|---|---|---|
| Etekcity scale | Coral-orange | Banner, application image, navigation icon | Hybrid exports pending native redraw |
| Etekcity blood pressure | Coral | Banner, application image, navigation icon | Hybrid exports pending native redraw |
| Trividia TRUE METRIX | Warm gold | Banner, application image, navigation icon | Hybrid exports pending native redraw |
| Viatom O2Ring | Oxygen blue with coral pulse | Banner, application image, navigation icon | Hybrid exports pending native redraw |
| Easy@Home BBT | Cycle plum | Banner, application image, navigation icon | Hybrid exports pending native redraw |

Each product's approved files are under `daemons/<product>/approved/`. Generated SVG and PNG derivatives are under `exports/`.

## Archived candidates

`archive/banner-candidates/` contains previous generated banner alternatives. They are retained to preserve provenance but are not approved for use. Files copied from deployed daemon repositories are the approved banner versions.

## SVG classification

The approved organization avatar and monochrome mark are native vectors. Other initial SVGs generated from current PNG artwork remain **hybrid SVGs**: they retain the approved raster image inside an SVG container with the correct dimensions and view box. They provide consistent SVG delivery without falsely presenting an automatic trace as editable native vector artwork.

A future native-vector redraw may replace a hybrid SVG after visual approval. The corresponding PNG remains the comparison reference during that review.
