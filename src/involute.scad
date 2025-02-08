include <constants.scad>
/**
  Evaluates the involute of a circle with radius r, for the parameter theta (in degrees)

  @param theta  Parameter (in degrees)
  @param r      Circle radius
*/
function circle_involute(theta, r) = let (c = cos(theta), s = sin(theta))
  r * [c + theta * D2R * s, s - theta * D2R * c];

/**
  Returns the parameter theta (in degrees) for the intersection between the involute 
  of a circle with radius (or diameter) r and another circle with radius (or diameter) R.

  @param r  Involute circle radius
  @param R  Radius of "the other circle" or just a distance from the origin
*/
function circle_involute_intersect(r, R) = R2D * sqrt(pow(R / r, 2) - 1);
