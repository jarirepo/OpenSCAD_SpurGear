include <./constants.scad>
include <./prop_helpers.scad>
include <./geom_helpers.scad>
include <./involute.scad>
include <./arc.scad>
include <./spur_gear_helpers.scad>

/*
  Gear rack initialization

  @param props      Properties obtained from `spur_gear_init`
  @param z          No. of teeth
  @param width      Gear rack width [mm]
  @param thickness  Gear rack thickness [mm]
  @param rf         Fillet radius [mm] (default: 0)
*/
function spur_gear_rack_init(props, z, width, thickness, rf = 0, res = DEFAULT_ARC_RES) =
  assert(z > 0, "No. of teeth (z) must be greater than 0")
  assert(width > 0, "Width must be greater than 0")
  assert(thickness > 0, "Thickness must be greater than 0")
  assert(rf >= 0, "Fillet radius must be greater than or equal to 0")
  assert(res > 0, "Resolution must be greater than 0")
  let (
    m = find_prop_value(SG_MODULE, props),
    b = find_prop_value(SG_DEDENDUM, props),
    alpha = find_prop_value(SG_PRESSURE_ANGLE, props),
    r = find_prop_value(SG_BASE_RADIUS, props),
    P = find_prop_value("P", props),

    pitch = PI * m,
    // Center line for the gear rack tooth (pointing outwards)
    w = normalize(P[3]),
    // Create the normal vector (wn) by rotating (w) by 90 degrees
    wn = w * RZ90,
    // Tangent points for the "pressure vector"
    T = circle_involute(alpha, r),
    Tm = mirror2(T, normalize(P[1])),
    Tm2 = mirror2(Tm, w),
    // Gear rack (A)ddendum and (D)edendum points along the tooth center line
    M = (Tm + Tm2) / 2,
    Pa = M - m * w,
    Pd = M + b * w,
    // Gear rack profile
    //  Solve for the rack segment starting point
    //  Intersect the vector (wn) through the points A and D, with the tangent (t) through the point (Tm)
    t = mirror2([cos(alpha), sin(alpha)], normalize(P[1])),
    R = [
      Pd - (pitch / 2) * wn,
      line_line_intersect(Pd, wn, Tm, t),
      line_line_intersect(Pa, wn, Tm, t)
    ],
    // Validate fillet radius
    v1 = normalize(R[1]-R[0]),
    v2 = normalize(R[2]-R[1]),
    tau = acos(v1 * v2),
    rfmax = norm(R[1]-R[0])/tan(tau / 2)
  )
  assert(rf <= rfmax, "Fillet radius is too large")
  let (
    // assert(rf <= rfmax, "Fillet radius is too large"), // this produces a warning!
    // Generate the rack profile by concatenating the rack segment with its mirror
    // rack_profile = concat(R, mirror2(reverse(R), w)),
    // Generate fillets
    A1 = gen_arc(wn, R[2]-R[1], rf, R[1], res),
    A2 = gen_arc(R[2]-R[1], wn, rf, R[2], res),
    pts = concat([R[0]], A1, A2, [R[2]]),
    rack_profile = concat(pts, mirror2(reverse(pts), w)),
    Pref = rack_profile[0] + thickness * w,
    // Generate the rack polygon (with the rack teeth) by sequential translations of the gear rack profile along the vector (wn)
    rack_polygon = [
      for (i = [0:z-1])
        let (T = i * pitch * wn - Pref)
        for (j = [0:len(rack_profile)-1])
          rack_profile[j] + T,
        rack_profile[0] - Pref + z * pitch * wn + thickness * w,
        rack_profile[0] - Pref + thickness * w
    ] * [[w[0], wn[0]], [w[1], wn[1]]] * RZ90N,
    // Needed for positioning of the gear rack, targeting a meshing pinion
    pressure_dist = norm(Tm), // distance from center of the pinion to the "pressure line",
    pressure_width = norm(Tm2 - Tm) // width of the "pressure line"
  )
[
  [SG_TYPE, SG_TYPE_RACK],
  [SG_MODULE, m],
  [SG_PRESSURE_ANGLE, alpha],
  [SG_DEDENDUM, b],
  [SG_NO_OF_TEETH, z],
  [SG_PITCH, pitch],
  [SG_WIDTH, width],
  [SG_THICKNESS, thickness],
  [SG_FILLET_R, rf],
  [SG_FILLET_R_MAX, rfmax],
  [SG_PRESSURE_DIST, pressure_dist],
  [SG_PRESSURE_WIDTH, pressure_width],
  [SG_PROFILE, rack_profile],
  [SG_POLYGON, rack_polygon],
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
function __pos(x, phi, r, m, b, alpha, dp, wp, p, t, phiR) = let (
  cosa = cos(phi - phiR),
  sina = sin(phi - phiR),
  A = [[cosa, sina], [-sina, cosa]],
  I = circle_involute(alpha, r),
  L = [
     (p + wp) / 2 + x[0],
    t + b + x[1]
  ]
) I * A - L;

/**
  Recursive Newton-Raphson solver (since OpenSCAD doesn't allow re-assigning variables)
*/
function _solve_translation(phi, r, m, b, alpha, dp, wp, p, t, phiR, x = [0, 0], it = 20, h = 1e-10, ftol = 1e-9) =
  let (
    fx = __pos(x, phi, r, m, b, alpha, dp, wp, p, t, phiR),
    J = [
      (__pos(x + [h, 0], phi, r, m, b, alpha, dp, wp, p, t, phiR) - fx) / h,
      (__pos(x + [0, h], phi, r, m, b, alpha, dp, wp, p, t, phiR) - fx) / h
    ],
    xx = x - fx * inv2(J),
    fnorm = norm(__pos(xx, phi, r, m, b, alpha, dp, wp, p, t, phiR))
  )
  (it > 0 && fnorm > ftol)
    ? _solve_translation(phi, r, m, b, alpha, dp, wp, p, t, phiR, xx, it - 1)
    : xx;

/**
  Returns the 4-by-4 transformation matrix to position gear rack to a pinion, along the direction vector (v)

    use multmatrix(T) to apply the transformation
*/
function rack_position(pinion, rack, v) =
  assert(
    find_prop_value(SG_TYPE, pinion) == SG_TYPE_PINION && find_prop_value(SG_TYPE, rack) == SG_TYPE_RACK,
    "Requires a pinion and a gear rack"
  )
  assert(check_compatibility(pinion, rack), "Incompatible pinion and gear rack")
  assert(len(v) == 2 && norm(v) > 0, "Invalid direction vector (v)")
  let (
    alpha = find_prop_value(SG_PRESSURE_ANGLE, rack),
    cp = find_prop_value(SG_CIRCULAR_PITCH, pinion),
    dp = find_prop_value(SG_PRESSURE_DIST, rack),
    wp = find_prop_value(SG_PRESSURE_WIDTH, rack),
    m = find_prop_value(SG_MODULE, rack),
    b = find_prop_value(SG_DEDENDUM, rack),
    r = find_prop_value(SG_BASE_RADIUS, pinion),
    p = find_prop_value(SG_PITCH, rack),
    t = find_prop_value(SG_THICKNESS, rack),
    v1 = [0, 1],
    v2 = -(v / norm(v)),
    dir = sign(cross(v1, v2)),
    phiR = dir * acos(v1 * v2),
    // Find index of a nearby tooth in the direction v
    phi = (atan2(v[1], v[0]) + 360) % 360,
    i = floor(phi / cp),
    X = _solve_translation(i * cp, r, m, b, alpha, dp, wp, p, t, phiR),
    Tr = X * [[cos(phiR), sin(phiR)], [-sin(phiR), cos(phiR)]]
    // Tr = [1.917335717376041e+01, -2.114875456925060e+00]
)
[
  // [cos(phiR), -sin(phiR), 0, -(dp + b + t) * v2[0]],
  // [sin(phiR), cos(phiR), 0, -(dp + b + t) * v2[1]],
  [cos(phiR), -sin(phiR), 0, Tr[0]],
  [sin(phiR), cos(phiR), 0, Tr[1]],
  [0, 0, 1, 0],
  [0, 0, 0, 1]
];

/*
  Create gear rack

  @param props  Properties obtained from `spur_gear_rack_init`
*/
module spur_gear_rack(props) {
  width = find_prop_value(SG_WIDTH, props);
  thickness = find_prop_value(SG_THICKNESS, props);
  rack_polygon = find_prop_value(SG_POLYGON, props);

  render(convexity = 2)
    linear_extrude(width)
      polygon(rack_polygon);
}
