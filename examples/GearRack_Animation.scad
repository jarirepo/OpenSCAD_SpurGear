use <OpenSCAD_SpurGear/SpurGear.scad>
assert(spurgear_required([1, 3, 0]), "Please upgrade SpurGear library to version 1.3.0 or higher");
include <../src/constants.scad>

/*
    To start the animation, select View -> Animate,
    and set FPS = 24 and Steps = 180
*/
gear = spur_gear_init(z = 32, m = 1.0, alpha = 20.0);

pinion = spur_gear_pinion_init(gear, w = 3.0, arc_resol = .05);
rack = spur_gear_rack_init(gear, z = 8, width = 3.0, thickness = 2.0, rf = .15, res = .05);

pinion_pitch = find_prop_value(SG_CIRCULAR_PITCH, pinion);
rack_pitch = find_prop_value(SG_PITCH, rack);

T = rack_position(pinion, rack, [-1,.5]);

k = sin(2 * ($t - .5) * 180);
ang = k * 30;
rotate([0, 0, ang])
spur_gear_pinion(pinion);

multmatrix(T)
translate([-3 * rack_pitch + (ang / pinion_pitch * rack_pitch), 0, 0])
  spur_gear_rack(rack);

// multmatrix(T12)
// rotate([0, 0, -$t * 360 * z1 / z2]) // -
// spur_gear_pinion(pinion2);    

// multmatrix(T12*T23)
// rotate([0, 0, $t*360 * z1 / z2 * z2 / z3]) // +
// spur_gear_pinion(pinion3);
