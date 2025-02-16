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
  m = find_prop_value(SG_MODULE, props),
  b = find_prop_value(SG_DEDENDUM, props),
  alpha = find_prop_value(SG_PRESSURE_ANGLE, props),
  z = find_prop_value(SG_NO_OF_TEETH, props),
  r = find_prop_value(SG_BASE_RADIUS, props),
  cp = find_prop_value(SG_CIRCULAR_PITCH, props),
  D = find_prop_value(SG_ADDENDUM_DIAMETER, props),
  Db = find_prop_value(SG_BASE_DIAMETER, props),
  Dr = find_prop_value(SG_ROOT_DIAMETER, props),
  Dc = find_prop_value(SG_CLEARANCE_DIAMETER, props),
  Dp = find_prop_value(SG_PITCH_DIAMETER, props),
  P = find_prop_value("P", props),

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
  profile_m = mirror2(reverse(profile), normalize(P[1])),
  // Included angle of the addendum arc
  v1 = normalize(profile[len(profile)-1]),
  v2 = normalize(profile_m[0]),
  ang_a = acos(v1*v2),
  Ta = [v1, [-v1[1], v1[0]]],
  // Included angle of the root arc
  u1 = normalize(profile[0]),
  u2 = normalize(profile_m[len(profile_m)-1]),
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
        c = (i == 0) ? 0 : cos(i * cp),
        s = (i == 0) ? 0 : sin(i * cp),
        Rz = (i == 0) ? [] : [[c, s], [-s, c]]
      )
      for (j = [0:len(pinion_profile)-1])
        (i == 0) ? pinion_profile[j] : pinion_profile[j] * Rz
  ]
) [
  [SG_TYPE, SG_TYPE_PINION],
  [SG_MODULE, m],
  [SG_PRESSURE_ANGLE, alpha],
  [SG_DEDENDUM, b],
  [SG_NO_OF_TEETH, z],
  [SG_CIRCULAR_PITCH, cp],
  [SG_WIDTH, w],
  [SG_ADDENDUM_DIAMETER, D],
  [SG_BASE_DIAMETER, Db],
  [SG_BASE_RADIUS, r],
  [SG_CLEARANCE_DIAMETER, Dc],
  [SG_PITCH_DIAMETER, Dp],
  [SG_ROOT_DIAMETER, Dr],
  [SG_POLYGON, pinion_polygon],
];

/**
  x[0] - alpha, pinion A involute parameter
  x[1] - gamma, pinion B rotation angle
  phiA - angle of the selected tooth on pinion A
  phiB - angle of the selected tooth on pinion B
  ra - radius of pinion A base circle
  rb - radius of pinion B base circle
  Ca - center of pinion A
  Cb - center of pinion B
*/
function _pos(x, phiA, phiB, ra, rb, Ca, Cb) = let (
  cosa = cos(phiA),
  sina = sin(phiA),
  cosb = cos(phiB + x[1]),
  sinb = sin(phiB + x[1]),
  A = [[cosa, sina], [-sina, cosa]],
  B = [[cosb, sinb], [-sinb, cosb]],
  beta = phiA + x[0] + 180 - phiB - x[1],
  Ia = circle_involute(x[0], ra),
  Ib = circle_involute(beta, rb)
) Ia * A - Ib * B - (Cb - Ca);

/**
  Recursive Newton-Raphson solver (since OpenSCAD doesn't allow re-assigning variables)
*/
function _solve_rotation(phiA, phiB, ra, rb, Ca, Cb, x = [180 / PI, 0], it = 20, h = 1e-10, ftol = 1e-9) =
  let (
    fx = _pos(x, phiA, phiB, ra, rb, Ca, Cb),
    J = [
      (_pos(x + [h, 0], phiA, phiB, ra, rb, Ca, Cb) - fx) / h,
      (_pos(x + [0, h], phiA, phiB, ra, rb, Ca, Cb) - fx) / h
    ],
    xx = x - fx * inv2(J),
    fnorm = norm(_pos(xx, phiA, phiB, ra, rb, Ca, Cb))
  )
  (it > 0 && fnorm > ftol)
    ? _solve_rotation(phiA, phiB, ra, rb, Ca, Cb, xx, it - 1)
    : xx[1];

/**
  Returns the 4-by-4 transformation matrix to position pinion 2 relative to pinion 1, along the direction vector (v)

    use multmatrix(T) to apply the transformation

  (After applying the transformation, the two pitch circles will become tangential)
*/
function pinion_position(props1, props2, v) = 
  assert(
    find_prop_value(SG_TYPE, props1) == SG_TYPE_PINION && find_prop_value(SG_TYPE, props2) == SG_TYPE_PINION,
    "Requires two pinions"
  )
  assert(check_compatibility(props1, props2), "Incompatible pinions")
  assert(len(v) == 2 && norm(v) > 0, "Invalid direction vector (v)")
  let (
    phiA = find_prop_value(SG_CIRCULAR_PITCH, props1),
    phiB = find_prop_value(SG_CIRCULAR_PITCH, props2),
    ra = find_prop_value(SG_BASE_RADIUS, props1),
    rb = find_prop_value(SG_BASE_RADIUS, props2),
    Dp1 = find_prop_value(SG_PITCH_DIAMETER, props1),  // Pitch circle diam. of pinion 1
    Dp2 = find_prop_value(SG_PITCH_DIAMETER, props2),  // Pitch circle diam. of pinion 2
    Ca = [0, 0],  // Center pt. of pinion 1
    Cb = (Dp1 + Dp2) / 2 * normalize(v),  // Center pt. of pinion 2
    // Find index of a nearby tooth in the direction v, on pinion A.
    // The algorithm is not sensitive to the choise of tooth on pinion B, but
    // we want to perform small rotations to not mess up the coordinate system when positioning
    // linked pinions.
    phi = (atan2(v[1], v[0]) + 360) % 360,
    i = floor(phi / phiA),
    j = floor(((phi + 180) % 360) / phiB),
    rz = _solve_rotation(i * phiA, j * phiB, ra, rb, Ca, Cb)
) [
  [cos(rz), -sin(rz), 0, Cb[0]],
  [sin(rz), cos(rz), 0, Cb[1]],
  [0, 0, 1, 0],
  [0, 0, 0, 1]
];

/**
  Create pinion

  @param props  Properties obtained from `spur_gear_pinion_init`
*/
module spur_gear_pinion(props) {
  width = find_prop_value(SG_WIDTH, props);
  pinion_polygon = find_prop_value(SG_POLYGON, props);
  
  render(convexity = 2)
    linear_extrude(width)
      polygon(pinion_polygon);
}
