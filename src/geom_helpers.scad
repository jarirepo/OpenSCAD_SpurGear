include <constants.scad>

/**
  Returns the number of line segments required to generate a curve at a given resolution.

  @param L    Curve length (line integral) [mm]
  @param res  Resolution [mm]
*/
function curve_segments(L, res) = min(MAX_ARC_SEGM, max(MIN_ARC_SEGM, floor(L / res + .5)));
