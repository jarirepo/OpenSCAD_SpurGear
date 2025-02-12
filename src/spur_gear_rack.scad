include <constants.scad>
include <prop_helpers.scad>
include <geom_helpers.scad>
include <involute.scad>
include <arc.scad>

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
    m = find_prop_value("m", props),
    b = find_prop_value("b", props),
    alpha = find_prop_value("alpha", props),
    r = find_prop_value("r", props),
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
    rfmax = norm(R[1]-R[0])/tan(tau / 2),
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
        rack_profile[0] - Pref + thickness * w,
    ] * [[w[0], wn[0]], [w[1], wn[1]]] * RZ90N
  )
  assert(rf <= rfmax, "Fillet radius is too large")
[
  ["type", TYPE_RACK],
  ["m", m],
  ["alpha", alpha],
  ["b", b],
  ["z", z],
  ["pitch", pitch],
  ["width", width],
  ["thickness", thickness],
  ["rf", rf],
  ["rfmax", rfmax],
  ["rack_profile", rack_profile],
  ["rack_polygon", rack_polygon],
];

/*
  Create gear rack

  @param props  Properties obtained from `spur_gear_rack_init`
*/
module spur_gear_rack(props) {
  width = find_prop_value("width", props);
  thickness = find_prop_value("thickness", props);
  rack_polygon = find_prop_value("rack_polygon", props);

  render(convexity = 2)
    linear_extrude(width)
      polygon(rack_polygon);
}
