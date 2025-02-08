include <constants.scad>

/**
  Returns the length of a circular arc

  @param theta  Included angle (degrees)
  @param r      Radius [mm]
*/
function arc_length(theta, r) = (theta * D2R) * r;
