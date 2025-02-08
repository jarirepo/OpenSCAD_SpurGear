include <VERSION.scad>
include <src/constants.scad>
include <src/prop_helpers.scad>
include <src/geom_helpers.scad>
include <src/arc.scad>
include <src/involute.scad>

/**
  Spur Gear Initialization

  @param m          Module (addendum) [mm]
  @param z          No. of teeth
  @param alpha      Pressure angle [deg]
  @param arc_resol  Arc resolution [mm]
*/
function spur_gear_init(z, m, alpha, arc_resol = 0.1) = let (
  Dp = m * z,           // Pitch circle diam.
  Db = Dp * cos(alpha), // Base circle diam.
  D = Dp + 2 * m,       // Addendum circle diam.
  Dc = Dp - 2 * m,      // Clearance circle diam.
  b = 1.25 * m,         // Dedendum
  Dr = Dp - 2 * b,      // Root circle diam.
  cp = 360 / z,         // Circular pitch angle, same as 2*PI*P/(PI*Dp)
  p = m * PI,           // Circular pitch length
  theta_p = circle_involute_intersect(Db, Dp),  // Intersection between the circle involute and the pitch circle
  theta_a = circle_involute_intersect(Db, D),    // Intersection between the circle involute and the addendum circle
  // Rotate the intersection point to get intermediate points along the pitch circle
  //  1/4: defines the vector used when mirroring
  //  3/4: used to construct the gear rack
  pp = circle_involute(theta_p, Db / 2),
  P = [
    pp,
    for (k = [1:4])
      let (a = k * cp / 4, c = cos(a), s = sin(a), Rz = [[c, s], [-s, c]])
      pp * Rz
  ],
  pa = circle_involute(theta_a, Db / 2),
  // Generate point along the gear tooth profile (from the base circle, theta=0, to the addendum circle, theta=theta_a)
  L = circle_involute_length(theta_a, Db / 2),
  N = curve_segments(L, arc_resol),  
  profile = [
    [Dr / 2, 0],
    for (k = [0:N])
      // let (theta = k * theta_a / N) // non-uniform arc length parametrization
      let (theta = circle_involute_param(k * L / N, Db / 2)) // uniform arc length parametrization
      circle_involute(theta, Db / 2)
  ],
  // Mirror the profile about the axis P[1], reversed order!
  axis1 = P[1] / norm(P[1]),
  A = [
    [axis1[0] * axis1[0], axis1[0] * axis1[1]],
    [axis1[1] * axis1[0], axis1[1] * axis1[1]]
  ],
  eye2 = [[1,0],[0,1]],
  profile_m = [
    for (k = [len(profile)-1:-1:0])
      let (v = profile[k])
      v + 2 * (eye2 - A) * (-v)
  ],
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
    let (u = k / Na) 
    (D / 2) * [cos(u * ang_a), sin(u * ang_a)] * Ta
  ],
  profile_r = [for (k = [0:Nr])
    let (u = k / Nr)
    (Dr / 2) * [cos(u * ang_r), sin(u * ang_r)] * Tr
  ],
  // Generate the complete polygon for the pinion by a sequence of rotations of the base profile about the z-axis
  pinion_profile = concat(profile, profile_a, profile_m, profile_r)
) [
  ["ver", VERSION],
  ["m", m],
  ["b", b],
  ["z", z],
  ["alpha", alpha],
  ["cp", cp],
  ["p", p],
  ["D", D],
  ["Db", Db],
  ["Dc", Dc],
  ["Dp", Dp],
  ["Dr", Dr],
  ["theta_p", theta_p],
  ["theta_a", theta_a],
  ["ang_a", ang_a],
  ["ang_r", ang_r],
  ["P", P],
  ["pinion_profile", pinion_profile],
];

/**
  Create pinion

  @param props  Properties obtained from `spur_gear_init`
  @param w      Pinion width [mm]
*/
module spur_gear_pinion(props, w) {
  z = find_prop_value("z", props);
  cp = find_prop_value("cp", props);
  pinion_profile = find_prop_value("pinion_profile", props);

  M = len(pinion_profile);
  pts = [
    for (i = [0:z-1])
      let (
        c = i == 0 ? 0 : cos(i * cp),
        s = i == 0 ? 0 : sin(i * cp),
        Rz = i == 0 ? [] : [[c, s], [-s, c]]
      )
      for (j = [0:M-1])
        i == 0 ? pinion_profile[j] : pinion_profile[j] * Rz
  ];

  render(convexity = 2)
  linear_extrude(w)
    polygon(pts);
}

/*
  Create gear rack

  @param props  Properties obtained from `spur_gear_init`
  @param z      No. of teeth
  @param w      Width
  @param t      Thickness
*/
module spur_gear_rack(props, z, w, t) {
}


/** Usage example */
module spur_gear_usage() {
  gear = spur_gear_init(z = 16, m = 0.75, alpha = 20.0, arc_resol = .05);
  echo(gear = gear);
  color("orange", alpha = .9);
  spur_gear_pinion(gear, w = 3.0);
}

spur_gear_usage();
