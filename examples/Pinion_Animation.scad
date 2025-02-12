use <OpenSCAD_SpurGear/SpurGear.scad>
assert(spurgear_required([1, 1, 0]), "Please upgrade SpurGear library to version 1.1.0 or higher");

/*
    To start the animation, select View -> Animate,
    and set FPS = 24 and Steps = 180
*/
gear1 = spur_gear_init(z = 15, m = 1.0, alpha = 20.0);
gear2 = spur_gear_init(z = 10, m = 1.0, alpha = 20.0);
gear3 = spur_gear_init(z = 30, m = 1.0, alpha = 20.0);

pinion1 = spur_gear_pinion_init(gear1, w = 3.0, arc_resol = .05);
pinion2 = spur_gear_pinion_init(gear2, w = 3.0, arc_resol = .05);
pinion3 = spur_gear_pinion_init(gear3, w = 3.0, arc_resol = .05);

T12 = pinion_position(pinion1, pinion2, [1,1]);
T23 = pinion_position(pinion2, pinion3, [2,-1]);

z1 = find_prop_value("z", pinion1);
z2 = find_prop_value("z", pinion2);
z3 = find_prop_value("z", pinion3);


rotate([0, 0, $t * 360]) //+
spur_gear_pinion(pinion1);

multmatrix(T12)
rotate([0, 0, -$t * 360 * z1 / z2]) // -
spur_gear_pinion(pinion2);    

multmatrix(T12*T23)
rotate([0, 0, $t*360 * z1 / z2 * z2 / z3]) // +
spur_gear_pinion(pinion3);
