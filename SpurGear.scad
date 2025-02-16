include <src/version.scad>
// include <src/constants.scad>
include <src/prop_helpers.scad>
include <src/spur_gear_init.scad>
include <src/spur_gear_pinion.scad>
include <src/spur_gear_rack.scad>

/*****************************************************************************
  spurgear_required(ver)
******************************************************************************
  Type:
    Function

  Description:
    Returns true if the library version is equal or greater than  the required 
    version.

  Parameters:
    ver - Semantic version [major, minor, patch]
*****************************************************************************/

/*****************************************************************************
  spur_gear_init(z, m, alpha)
******************************************************************************
  Type:
    Function

  Description:
    Spur Gear Initialization

  Parameters:
    m - Module (addendum) [mm]
    z - No. of teeth
    alpha - Pressure angle [deg]
*****************************************************************************/

/*****************************************************************************
  spur_gear_pinion_init(props, w, arc_resol = DEFAULT_ARC_RES)
******************************************************************************
  Type:
    Function

  Description:
    Pinion initialization

  Parameters:
    props - Properties obtained from `spur_gear_init`
    w - Width [mm]
    arc_resol - Arc resolution [mm] (default: DEFAULT_ARC_RES)
*****************************************************************************/

/*****************************************************************************
  pinion_position(props1, props2, v)
******************************************************************************
  Type:
    Function

  Description:
    Returns the position of the pinion 1 to mesh with pinion 2 in a given
    direction.

  Parameters:
    props1 - Properties of pinion 1 obtained from `spur_gear_pinion_init`
    props2 - Properties of pinion 2 obtained from `spur_gear_pinion_init`
    v - Direction vector [vx, vy] pointing from pinion 1 to pinion 2
*****************************************************************************/

/*****************************************************************************
  spur_gear_pinion(props)
******************************************************************************
  Type:
    Module
  
  Description:
    Create pinion

  Parameters:
    props - Properties obtained from `spur_gear_pinion_init`
*****************************************************************************/

/*****************************************************************************
  spur_gear_rack_init(props, z, width, thickness, rf = 0, res = DEFAULT_ARC_RES)
******************************************************************************
  Type:
    Function

  Description:
    Gear rack initialization

  Parameters:
    props - Properties obtained from `spur_gear_init`
    z - No. of teeth
    width - Gear rack width [mm]
    thickness - Gear rack thickness [mm]
    rf - Fillet radius [mm] (default: 0)
    res - Arc resolution [mm] (default: DEFAULT_ARC_RES)
*****************************************************************************/

/*****************************************************************************
  spur_gear_rack(props)
******************************************************************************
  Type:
    Module

  Description:
    Create gear rack

  Parameters:
    props - Properties obtained from `spur_gear_rack_init`
*****************************************************************************/
