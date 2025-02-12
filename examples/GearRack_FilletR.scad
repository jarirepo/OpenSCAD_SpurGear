use <../SpurGear.scad>
assert(spurgear_required([1, 2, 0]), "Please upgrade SpurGear library to version 1.2.0 or higher");

gear = spur_gear_init(z = 16, m = 0.75, alpha = 20.0);
rack = spur_gear_rack_init(gear, z = 5, width = 3.0, thickness = 1.0, rf = .1, res = .01);

echo(rack = rack);

// translate([0, 3.0, 0])
// rotate([90, 0, 0])
spur_gear_rack(rack);
