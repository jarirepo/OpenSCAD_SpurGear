# Changelog

## [Unreleased]
### Changed
- 1.2.0 PNG and STL files inside separate folders in examples folder

## [1.2.0][1.2.0]
### Added
- Gear rack fillet radius

## [1.1.2][1.1.2]
### Added
- Added example `Pinion_Animation`
### Changed
- Corrected example `Pinion_Pinion_Positioning` to use matrix multiplications instead of nested transformations.
### Deleted
- `VERSION.scad`

## [1.1.1][1.1.1]
### Added
- Function `spurgear_required` included in `src/version.scad` that should be used to make assertion on `SpurGear` library version
### Changed
- Updated examples

## [1.1.0][1.1.0]
### Added
- 1.0.0 Positioning of two or more meshing pinions

## [1.0.0][1.0.0]
### Performance
- Reduced computations when generating pinions
### Added
- Create meshing gear rack
### Changed
- Modularized implementation with separate initializations of pinions and gear racks

## [0.2.1]
### Changed
- Uniform arc length parametrization when generating the circle involute

## [0.2.0]
### Changed
- Controllable gear resolution

## [0.1.0]
### Added
- Create pinion

[Unreleased]: https://github.com/jarirepo/OpenSCAD_SpurGear/tree/dev

[1.2.0]: https://github.com/jarirepo/OpenSCAD_SpurGear/compare/v1.1.2...v1.2.0
[1.1.2]: https://github.com/jarirepo/OpenSCAD_SpurGear/compare/v1.1.1...v1.1.2
[1.1.1]: https://github.com/jarirepo/OpenSCAD_SpurGear/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/jarirepo/OpenSCAD_SpurGear/compare/1.0.0...v1.1.0
[1.0.0]: https://github.com/jarirepo/OpenSCAD_SpurGear/compare/v0.2.1...1.0.0
[0.2.1]: https://github.com/jarirepo/OpenSCAD_SpurGear/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/jarirepo/OpenSCAD_SpurGear/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/jarirepo/OpenSCAD_SpurGear/compare/v0.1.0...v0.1.0
