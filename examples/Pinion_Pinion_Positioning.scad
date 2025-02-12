use <../SpurGear.scad>
assert(spurgear_required([1, 1, 0]), "Please upgrade SpurGear library to version 1.1.0 or higher");

/**
  This example shows how to properly align three meshing spur gear pinions
*/
module Pinion_Pinion_Positioning() {
  // For gears to mesh properly, the module (or addendum) (m) and pressure angle (alpha) must be the same!
  gear1 = spur_gear_init(z = 16, m = 1.0, alpha = 20.0);
  gear2 = spur_gear_init(z = 32, m = 1.0, alpha = 20.0);
  gear3 = spur_gear_init(z = 13, m = 1.0, alpha = 20.0);

  echo(gear1 = gear1);
  echo(gear2 = gear2);
  echo(gear3 = gear3);

  pinion1 = spur_gear_pinion_init(gear1, w = 3.0, arc_resol = .05);
  pinion2 = spur_gear_pinion_init(gear2, w = 3.0, arc_resol = .05);
  pinion3 = spur_gear_pinion_init(gear3, w = 3.0, arc_resol = .05);

  // T12 = pinion_position(pinion1, pinion2, [0, 0]); // invalid!

  // T12 = pinion_position(pinion1, pinion2, [-1, 0]);
  // T12 = pinion_position(pinion1, pinion2, [1.5, .55]);
  // T12 = pinion_position(pinion1, pinion2, [1.8, 1.3]);
  // T12 = pinion_position(pinion1, pinion2, [-.3, 1]);
  // T12 = pinion_position(pinion1, pinion2, [.1, -1]);
  // T12 = pinion_position(pinion1, pinion2, [-1.0, .025]);
  
  // Calc. transformation for pinion 2 to mesh with pinion 1
  T12 = pinion_position(pinion1, pinion2, [1, 0]);
  // Calc. transformation for pinion 3 to mesh with pinion 2
  T23 = pinion_position(pinion2, pinion3, [1.5, 1]);
  // Calc. transformation for pinion 4 to mesh with pinion 3. Note that pinion 4 uses the same model as pinion 1
  T34 = pinion_position(pinion3, pinion1, [1, -5]);

  echo(T12 = T12, T23 = T23, T34 = T34);

  // Use multmatrix to apply the transformation (translation and rotation)
  translate([15, 20, 0]) {
    spur_gear_pinion(pinion1);
    // Pinion 2    
    multmatrix(T12)
      spur_gear_pinion(pinion2);
    // Pinion 3
    multmatrix(T12 * T23)
      spur_gear_pinion(pinion3);
    // Pinion 4 (uses the same model as pinion 1)
    multmatrix(T12 * T23 * T34)
      spur_gear_pinion(pinion1);
  }
}

Pinion_Pinion_Positioning();
