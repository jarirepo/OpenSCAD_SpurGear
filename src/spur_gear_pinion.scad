include <constants.scad>
include <prop_helpers.scad>
include <geom_helpers.scad>
include <arc.scad>
include <involute.scad>

/**
  Pinion initialization

  @param props      Properties obtained from `spur_gear_init`
  @param w          Width [mm]
  @param arc_resol  Arc resolution [mm]
*/
function spur_gear_pinion_init(props, w, arc_resol = DEFAULT_ARC_RES) =
  assert(w > 0, "Width (w) must be greater than 0")
  assert(arc_resol > 0, "Arc resolution (arc_resol) must be greater than 0")
 let (
  m = find_prop_value("m", props),
  b = find_prop_value("b", props),
  alpha = find_prop_value("alpha", props),
  z = find_prop_value("z", props),
  r = find_prop_value("r", props),
  P = find_prop_value("P", props),
  cp = find_prop_value("cp", props),
  D = find_prop_value("D", props),
  Db = find_prop_value("Db", props),
  Dr = find_prop_value("Dr", props),
  Dc = find_prop_value("Dc", props),
  Dp = find_prop_value("Dp", props),

  theta_a = circle_involute_intersect(Db, D),    // Intersection between the circle involute and the addendum circle
  // pa = circle_involute(theta_a, r),
  // Generate point along the gear tooth profile (from the base circle, theta=0, to the addendum circle, theta=theta_a)
  L = circle_involute_length(theta_a, r),
  N = curve_segments(L, arc_resol),  
  profile = [
    [Dr / 2, 0],
    for (k = [0:N])
      // let (theta = k * theta_a / N) // non-uniform arc length parametrization
      let (theta = circle_involute_param(k * L / N, r)) // uniform arc length parametrization
      circle_involute(theta, r)
  ],
  // Mirror the gear profile about the axis P[1], reversed order
  profile_m = mirror2(reverse(profile), P[1] / norm(P[1])),
  // Included angle of the addendum arc
  v1 = profile[len(profile)-1] / norm(profile[len(profile)-1]),
  v2 = profile_m[0] / norm(profile_m[0]),
  ang_a = acos(v1*v2),
  Ta = [v1, [-v1[1], v1[0]]],
  // Included angle of the root arc
  u1 = profile[0] / norm(profile[0]),
  u2 = profile_m[len(profile_m)-1] / norm(profile_m[len(profile_m)-1]),
  ang_r = cp - acos(u1*u2),
  Tr = [u2, [-u2[1], u2[0]]],
  // Generate points on the addendum and root arcs (for the gear tooth profile)
  Na = curve_segments(arc_length(ang_a, D / 2), arc_resol),
  Nr = curve_segments(arc_length(ang_r, Dr / 2), arc_resol),
  profile_a = [for (k = [0:Na])
    (D / 2) * [cos(k * ang_a / Na), sin(k * ang_a / Na)] * Ta
  ],
  profile_r = [for (k = [0:Nr])
    (Dr / 2) * [cos(k * ang_r / Nr), sin(k * ang_r / Nr)] * Tr
  ],
  // Generate the complete polygon for the pinion by a sequence of rotations of the base profile about the z-axis
  pinion_profile = concat(profile, profile_a, profile_m, profile_r),
  pinion_polygon = [
    for (i = [0:z-1])
      let (
        c = i == 0 ? 0 : cos(i * cp),
        s = i == 0 ? 0 : sin(i * cp),
        Rz = i == 0 ? [] : [[c, s], [-s, c]]
      )
      for (j = [0:len(pinion_profile)-1])
        i == 0 ? pinion_profile[j] : pinion_profile[j] * Rz
  ]
) [
  ["m", m],
  ["alpha", alpha],
  ["b", b],
  ["z", z],
  ["cp", cp],
  ["w", w],
  ["D", D],
  ["Db", Db], ["r", r],
  ["Dc", Dc],
  ["Dp", Dp],
  ["Dr", Dr],
  ["pinion_polygon", pinion_polygon],
];

/**
  Create pinion

  @param props  Properties obtained from `spur_gear_pinion_init`
*/
module spur_gear_pinion(props) {
  w = find_prop_value("w", props);
  pinion_polygon = find_prop_value("pinion_polygon", props);
  
  render(convexity = 2)
    linear_extrude(w)
      polygon(pinion_polygon);
}
