include <constants.scad>
include <geom_helpers.scad>

/**
  Returns the length of a circular arc

  @param theta  Included angle (degrees)
  @param r      Radius [mm]
*/
function arc_length(theta, r) = (theta * D2R) * r;

/*
  Generates a circular arc by a modified version of the "Circle Spline" algorithm.
  
  Endpoint tangents and radius are given.
  The intersection point (corner) is located at C.
  Not possible here to check if the radius is too large w.r.t. the geometry.

  @param v1   Direction of the 1st line
  @param v2   Direction of the 2nd line
  @param r    Fillet radius
  @param C    Corner point [xc, yc] (default: [0, 0])
  @param res  Arc resolution (default: DEFAULT_ARC_RES)
*/
function gen_arc(v1, v2, r, C = [0, 0], res = DEFAULT_ARC_RES) = let (
  a = normalize(v1),
  b = normalize(v2),
  tau = acos(a * b),
  zdir = sign(cross(a, b)),
  N = curve_segments(arc_length(tau, r), res),
  dtau = zdir * (tau / 2) / N,
  c = r * sqrt(2 * (1 - cos(tau))),
  d = r * tan(tau / 2),
  p0 = -d * a,
  V = [
    a,
    for (i = [1:N])
      let (cc = cos(i * dtau), ss = sin(i * dtau))
      a * [[cc, ss],[-ss, cc]]
  ]
) [
  C + p0,
  for (i = [1:N])
    let (
      u = i / N,
      tau_u = u * tau / 2,
      r_u = c * sin(u * tau_u) / sin(tau_u)
    )
    C + p0 + r_u * V[i]
];
