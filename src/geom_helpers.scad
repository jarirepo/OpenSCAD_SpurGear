include <constants.scad>

/**
  Returns the number of line segments required to generate a curve at a given resolution.

  @param L    Curve length (line integral) [mm]
  @param res  Resolution [mm]
*/
function curve_segments(L, res) = min(MAX_ARC_SEGM, max(MIN_ARC_SEGM, floor(L / res + .5)));

/**
  Mirrors the 2D-vector(s) in v about the axis a

  Usage:
    P = [[1, 0], [1, 1], [1, 2]];
    a = [0, 1];
    Pm = mirror2(P, a);

  @param v  Vector(s) to mirror [[v0], [v1], ..., [vn]]
  @param a  Mirror axis: a = [ax, ay]
*/
function mirror2(v, a) = let (
    // a * a'
    A = [
      [a[0] * a[0], a[0] * a[1]],
      [a[1] * a[0], a[1] * a[1]]
    ]
  )
  v - 2 * v * (EYE2 - A);

/**
  Reverses the order of the items in the given array

  Usage:
    P = [[0,1],[1,0],[2,1], [2,2],[1,3],[0,2]];
    Pr = reverse(P);

  @param arr  1-dimensional array with items of any type
*/
function reverse(arr) = [for (k = [len(arr)-1:-1:0]) arr[k]];

/**
  Inverse of 2-by-2 matrix
*/
function inv2(A) = let (detA = A[0][0] * A[1][1] - A[0][1] * A[1][0])
  [[A[1][1], -A[0][1]], [-A[1][0], A[0][0]]] / detA;

/**
  Returns the intersection between two lines given in parametric form

  Line 1: P + s * u
  Line 2: Q + t * v
*/
function line_line_intersect(P, u, Q, v) = let (
    x = [Q - P] * inv2([u, -v])
  )
  P + x[0][0] * u;
