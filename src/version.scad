include <./constants.scad>

function spurgear_required(ver) =
  assert(len(ver) == 3, "Version array must have three semantic version elements")
  SG_SEMVER[0] >= ver[0] && SG_SEMVER[1] >= ver[1] && SG_SEMVER[2] >= ver[2];
