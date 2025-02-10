use <../SpurGear.scad>

module PinionWithIndendation() {
  gear = spur_gear_init(z = 16, m = 0.75, alpha = 20.0);
  pinion_props = spur_gear_pinion_init(gear, w = 3.0, arc_resol = .05);

  difference() {
    spur_gear_pinion(pinion_props);
    translate([0, 0, 2.5])
      cylinder(h = .5 + 1e-2, d = 5, center = false);
  }
}

PinionWithIndendation($fn = 50);
