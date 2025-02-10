use <../SpurGear.scad>

module GearRacks() {
  gear = spur_gear_init(z = 16, m = 0.75, alpha = 20.0);
  gear_rack_props1 = spur_gear_rack_init(gear, z = 5, width = 3.0, thickness = 2.0);
  gear_rack_props2 = spur_gear_rack_init(gear, z = 10, width = 5.0, thickness = 1.0);
  gear_rack_props3 = spur_gear_rack_init(gear, z = 15, width = 1.5, thickness = 5.0);

  translate([0, 3.0, 0])
  rotate([90, 0, 0])
  spur_gear_rack(gear_rack_props1);

  translate([0, 10 + 5.0, 0])
  rotate([90, 0, 0])
  spur_gear_rack(gear_rack_props2);

  z3 = find_prop_value("z", gear_rack_props3);
  pitch3 = find_prop_value("pitch", gear_rack_props3);

  translate([0, 20 + 1.5, 0])
  rotate([90, 0, 0])
  difference() {
    spur_gear_rack(gear_rack_props3);
    translate([2*pitch3, 5.0/2, -1e-2])
      cylinder(h = 1.5 + 2e-2, d = 2.15, center = false);
    translate([(z3-2)*pitch3, 5.0/2, -1e-2])
      cylinder(h = 1.5 + 2e-2, d = 2.15, center = false);
  }
}

GearRacks($fn = 50);
