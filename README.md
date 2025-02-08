# OpenSCAD_SpurGear
A library for [OpenSCAD][OpenSCAD] to create [spur gear][spur-gear] geometry for [pinions][pinion] and meshing gear racks (not yet supported).

<img src="docs/SpurGear_Pinion_1.png">

## Features
- Fast calculations based on analytical formulas and pre-calculation of the intrinsic properties
- Uniform arc length parametrization used when generating the gear profile (adjustable resolution)

# Installing the module in OpenSCAD
Clone this repository and copy the folder `OpenSCAD_SpurGear` to the OpenSCAD libraries folder, [read more][OpenSCAD-libraries].

## Usage example

```scad
use <OpenSCAD_SpurGear/SpurGear.scad>

gear = spur_gear_init(z = 16, m = 0.75, alpha = 20.0, arc_resol = .1);
echo(gear = gear);

color("orange", alpha = .5);
spur_gear_pinion(gear, w = 3.0);
```

In VS Code, install the [OpenSCAD][OpenSCAD-Ext] and [OpenSCAD Language Support][OpenSCAD-Language-Support-Ext] extensions.

[OpenSCAD]: https://openscad.org/
[OpenSCAD-libraries]: https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Libraries
[OpenSCAD-Ext]: https://marketplace.visualstudio.com/items?itemName=Antyos.openscad
[OpenSCAD-Language-Support-Ext]: https://marketplace.visualstudio.com/items?itemName=Leathong.openscad-language-support
[spur-gear]: https://en.wikipedia.org/wiki/Spur_gear
[pinion]: https://en.wikipedia.org/wiki/Pinion
[spur-gears]: https://www.academia.edu/45138344/The_Geometry_of_Involute_Gears
