# OpenSCAD_SpurGear
A library for [OpenSCAD][OpenSCAD] to create [spur gear][spur-gear] geometry for [pinions][pinion] and meshing gear racks.

<!-- <img src="docs/SpurGear_Pinion_1.png"> -->
<img src="docs/SpurGear_Pinion_GearRack_1.png">

## Features
- Fast calculations based on analytical formulas and pre-calculation of the intrinsic properties.
- Uniform arc length parametrization used when generating the gear profile (adjustable resolution).

# Installing the module in OpenSCAD
Clone this repository and copy the folder `OpenSCAD_SpurGear` to the OpenSCAD libraries folder, [read more][OpenSCAD-libraries].

In VS Code, install the [OpenSCAD][OpenSCAD-Ext] and [OpenSCAD Language Support][OpenSCAD-Language-Support-Ext] extensions.

## Usage examples

### Create pinion
```scad
use <OpenSCAD_SpurGear/SpurGear.scad>

gear = spur_gear_init(z = 16, m = 1.0, alpha = 20.0);
echo(gear = gear);

pinion_props = spur_gear_pinion_init(gear, w = 3.0, arc_resol = .05);

spur_gear_pinion(pinion_props);
```

### Create gear rack
```scad
use <OpenSCAD_SpurGear/SpurGear.scad>

gear = spur_gear_init(z = 16, m = 1.0, alpha = 20.0);
echo(gear = gear);

gear_rack_props = spur_gear_rack_init(gear, z = 10, width = 3.0, thickness = 2.0);

//translate([0, 3.0, 0])
//rotate([90, 0, 0])
spur_gear_rack(gear_rack_props);
```
More examples can be found in the `examples` folder.

[OpenSCAD]: https://openscad.org/
[OpenSCAD-libraries]: https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Libraries
[OpenSCAD-Ext]: https://marketplace.visualstudio.com/items?itemName=Antyos.openscad
[OpenSCAD-Language-Support-Ext]: https://marketplace.visualstudio.com/items?itemName=Leathong.openscad-language-support
[spur-gear]: https://en.wikipedia.org/wiki/Spur_gear
[pinion]: https://en.wikipedia.org/wiki/Pinion
[spur-gears]: https://www.academia.edu/45138344/The_Geometry_of_Involute_Gears
[circle-involute]: https://en.wikipedia.org/wiki/Involute
