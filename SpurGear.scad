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

  N = len(pinion_profile);
  pts = [
    for (i = [0:z-1])
      let (
        c = i == 0 ? 0 : cos(i * cp),
        s = i == 0 ? 0 : sin(i * cp),
        Rz = i == 0 ? [] : [[c, s], [-s, c]]
      )
      for (j = [0:N-1])
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
  @param w      Width [mm]
  @param t      Thickness [mm]
*/
module spur_gear_rack(props, z, width, thickness) {
  assert(z > 0, "No. of teeth (z) must be greater than 0");
  assert(width > 0, "Width must be greater than 0");
  assert(thickness > 0, "Thickness must be greater than 0");

  m = find_prop_value("m", props);
  b = find_prop_value("b", props);
  alpha = find_prop_value("alpha", props);
  Db = find_prop_value("Db", props);
  P = find_prop_value("P", props);

  // Center line for the gear rack tooth (pointing outwards)
  w = P[3] / norm(P[3]);
  // Create the normal vector (wn) by rotating (w) by 90 degrees
  wn = w * RZ90;  
 
  // Tangent points for the "pressure vector"
  T = circle_involute(alpha, Db / 2);
  Tm = mirror2(T, P[1] / norm(P[1]));
  Tm2 = mirror2(Tm, w);

  // Gear rack (A)ddendum and (D)edendum points along the tooth center line
  M = (Tm + Tm2) / 2;
  Pa = M - m * w;
  Pd = M + b * w;

  // Gear rack profile
  //  Solve for the rack segment starting point
  //  Intersect the vector (wn) through the points A and D, with the tangent (t) through the point (Tm)
  t = mirror2([cos(alpha), sin(alpha)], P[1] / norm(P[1]));
  _width = m * PI;
  R = [
    Pd - (_width / 2) * wn,
    line_line_intersect(Pd, wn, Tm, t),
    line_line_intersect(Pa, wn, Tm, t)
  ];
  rack_profile = concat(R, mirror2(reverse(R), w));

  // Generate the rack polygon (with the rack teeth) by sequential translations of the gear rack profile along the vector (wn)
  N = len(rack_profile);
  pts = [
    for (i = [0:z-1])
      let (T = i * _width * wn)
      for (j = [0:N-1])
        rack_profile[j] + T,
      // Add thickness
      rack_profile[0] + z * _width * wn + thickness * w,
      rack_profile[0] + thickness * w,
  ];

  linear_extrude(width)
    polygon(pts);

  echo(w = w, wn = wn, M = M, Pa = Pa, Pd = Pd, t = t, rack_profile = rack_profile, width = _width, pts = pts);
}

/** Usage example */
module spur_gear_usage() {
  gear = spur_gear_init(z = 16, m = 0.75, alpha = 20.0, arc_resol = .1);
  echo(gear = gear);

  color("orange", alpha = .9);
  spur_gear_pinion(gear, w = 3.0);

  color("red", alpha = .9);
  translate([0, 0, 0])
  spur_gear_rack(gear, z = 10, width = 3.0, thickness = 2.0);

  // Pm = mirror2(
  //   [[1, 0], [1, 1], [1, 2]],
  //   [0, 1]
  // );
  // echo(Pm = Pm);

  // P = [[0,1],[1,0],[2,1], [2,2],[1,3],[0,2]];
  // echo(reverse(P));

  // echo(inv2([[4, 1], [-3, 2]]));
  // I = line_line_intersect(
  //   [0, 0], [1, 0],
  //   [1, 1], [0, -1]
  // );
  // echo(I = I);
  // p = [0, 0];
  // q = [1, 0];
  // u = [1, 0];
  // v = [0, -1];
  // // C = [[u[0], v[0]], [u[1], v[1]]];
  // C = [u, -v];
  // echo([p - q] * inv2(C));
}

spur_gear_usage();
