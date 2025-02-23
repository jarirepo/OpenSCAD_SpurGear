use <../SpurGear.scad>
assert(spurgear_required([1, 3, 0]), "Please upgrade SpurGear library to version 1.3.0 or higher");
include <../src/constants.scad>

/**
  This example shows how to align a pinion with a meshing gear rack.

  The positioning is performed on the XY-plane.
*/

gear = spur_gear_init(z = 32, m = 1.0, alpha = 20.0);
echo(gear = gear);

pinion = spur_gear_pinion_init(gear, w = 3.0, arc_resol = .05);
rack = spur_gear_rack_init(gear, z = 5, width = 3.0, thickness = 2.0, rf = .15, res = .01);

echo(pinion = pinion);
echo(rack = rack);

rack_pitch = find_prop_value(SG_PITCH, rack);

spur_gear_pinion(pinion);

// T = rack_position(pinion, rack, [0, 1]); // right
// T = rack_position(pinion, rack, [-1, 0]); // top
// T = rack_position(pinion, rack, [0, -1]); // left
// T = rack_position(pinion, rack, [1, 0]); // bottom
T = rack_position(pinion, rack, [-1, 1]);
echo(T = T);

color("gold", alpha = .75)
multmatrix(T)
translate([-2 * rack_pitch, 0, 0])
  spur_gear_rack(rack);

echo(gear = gear);
