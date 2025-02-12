SPURGEAR_SEMVER = [1, 1, 2];

function spurgear_required(ver) =
  assert(len(ver) == 3, "Version array must have three semantic version elements")
  SPURGEAR_SEMVER[0] >= ver[0] && SPURGEAR_SEMVER[1] >= ver[1] && SPURGEAR_SEMVER[2] >= ver[2];
