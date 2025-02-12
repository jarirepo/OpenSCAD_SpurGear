include <src/version.scad>
include <src/prop_helpers.scad>
include <src/spur_gear_init.scad>
include <src/spur_gear_pinion.scad>
include <src/spur_gear_rack.scad>

/*****************************************************************************
  spur_gear_init(z, m, alpha)
******************************************************************************
  Spur Gear Initialization

  Parameters:
    m - Module (addendum) [mm]
    z - No. of teeth
    alpha - Pressure angle [deg]
*****************************************************************************/

/*****************************************************************************
  spur_gear_pinion_init(props, w, arc_resol = DEFAULT_ARC_RES)
******************************************************************************
  Pinion initialization

  Parameters:
    props - Properties obtained from `spur_gear_init`
    w - Width [mm]
    arc_resol - Arc resolution [mm]
*****************************************************************************/

/*****************************************************************************
  spur_gear_pinion(props)
******************************************************************************
  Create pinion

  Parameters:
    props - Properties obtained from `spur_gear_pinion_init`
*****************************************************************************/

/*****************************************************************************
  spur_gear_rack_init(props, z, width, thickness)
******************************************************************************
  Gear rack initialization

  Parameters:
    props - Properties obtained from `spur_gear_init`
    z - No. of teeth
    width - Gear rack width [mm]
    thickness - Gear rack thickness [mm]
*****************************************************************************/

/*****************************************************************************
  spur_gear_rack(props)
******************************************************************************
  Create gear rack

  Parameters:
    props - Properties obtained from `spur_gear_rack_init`
*****************************************************************************/
