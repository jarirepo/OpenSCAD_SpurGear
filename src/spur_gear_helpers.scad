include <prop_helpers.scad>

function check_compatibility(g1, g2) =
  find_prop_value("m", g1) == find_prop_value("m", g2) &&
  find_prop_value("alpha", g1) == find_prop_value("alpha", g2);
