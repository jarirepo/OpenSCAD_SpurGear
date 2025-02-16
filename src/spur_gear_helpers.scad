include <constants.scad>
include <prop_helpers.scad>

function check_compatibility(g1, g2) =
  find_prop_value(SG_MODULE, g1) == find_prop_value(SG_MODULE, g2) &&
  find_prop_value(SG_PRESSURE_ANGLE, g1) == find_prop_value(SG_PRESSURE_ANGLE, g2);
