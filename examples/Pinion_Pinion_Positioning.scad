use <../SpurGear.scad>

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

  T34 = pinion_position(pinion3, pinion1, [1, -5]);

  echo(T12 = T12);
  echo(T23 = T23);

  // No more manuallly set rotation angle!
  // spur_gear_pinion(pinion1);
  // rotate([0, 0, ?])
  //   spur_gear_pinion(pinion2);

  // Use multmatrix to apply the transformation (translation and rotation)
  translate([15, 20, 0]) {
    spur_gear_pinion(pinion1);
    multmatrix(T12) {
      spur_gear_pinion(pinion2);
      // Pinion 3 is relative to the pinion 2 coordinate system
      multmatrix(T23) {
        spur_gear_pinion(pinion3);
        // Pinion 4 (uses the same model as pinion 1) is relative to the pinion 3 coordinate system
        multmatrix(T34) {
          spur_gear_pinion(pinion1);
        }
      }
    }
  }
}

Pinion_Pinion_Positioning();
