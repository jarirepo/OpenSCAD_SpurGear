include <constants.scad>
/**
  Returns the number of line segments required to generate a circular arc witch include
  angle (a) and radius (r) to the given resolution (res)

  @param a    Include angle (degrees)
  @param r    Radius [mm]
  @param res  Resolution [mm]
*/
function arc_segments(a, r, res) = min(MAX_ARC_SEGM, max(MIN_ARC_SEGM, floor(a * D2R * r / res + .5)));
