include <../VERSION.scad>
include <constants.scad>
include <prop_helpers.scad>
include <geom_helpers.scad>
include <arc.scad>
include <involute.scad>

/**
  Spur Gear Initialization

  @param m          Module (addendum) [mm]
  @param z          No. of teeth
  @param alpha      Pressure angle [deg]
*/
function spur_gear_init(z, m, alpha) =
  assert(z > 0, "No. of teeth (z) must be greater than 0")
  assert(m > 0, "Module (m) must be greater than 0")
  assert(alpha > 0, "Pressure angle (alpha) must be greater than 0")
  let (
  Dp = m * z,           // Pitch circle diam.
  Db = Dp * cos(alpha), // Base circle diam.
  r = Db / 2,
  D = Dp + 2 * m,       // Addendum circle diam.
  Dc = Dp - 2 * m,      // Clearance circle diam.
  b = 1.25 * m,         // Dedendum
  Dr = Dp - 2 * b,      // Root circle diam.
  cp = 360 / z,         // Circular pitch angle, same as 2*PI*P/(PI*Dp)
  theta_p = circle_involute_intersect(Db, Dp),  // Intersection between the circle involute and the pitch circle
  // Generate the "construction points"
  // Rotate the intersection point to get intermediate points along the pitch circle
  //  1/4: defines the vector used when mirroring
  //  3/4: used to construct the gear rack
  pp = circle_involute(theta_p, r),
  P = [
    pp,
    for (k = [1:4])
      let (a = k * cp / 4, c = cos(a), s = sin(a), Rz = [[c, s], [-s, c]])
      pp * Rz
  ]
) [
  ["m", m],
  ["alpha", alpha],
  ["b", b],
  ["z", z],
  ["cp", cp],
  ["D", D],
  ["Db", Db], ["r", r],
  ["Dc", Dc],
  ["Dp", Dp],
  ["Dr", Dr],
  ["P", P],
  ["ver", VERSION],
];
