// v136 arm D — HOMES: $unit class, package class, module class, inheritance, instances.
typedef struct packed { bit [3:0] unitLo; bit [3:0] unitHi; } unitSpan_S;
typedef union  packed { bit [7:0] unitW;  bit [7:0] unitV;  } unitWrap_U;

class UnitHome;
  unitSpan_S d01_unitProp;
  unitWrap_U d02_unitUnion;
endclass

package Pk_Homes;
  typedef struct packed { bit [5:0] pkA; bit [2:0] pkB; } pkgSpan_S;
  class PkgBase;
    pkgSpan_S d03_baseProp;
  endclass
  class PkgDerived extends PkgBase;         // INHERITS d03; adds its own
    pkgSpan_S d04_derivedProp;
  endclass
  virtual class PkgVirt;
    pkgSpan_S d05_virtProp;
  endclass
  class PkgConcrete extends PkgVirt;
    pkgSpan_S d06_concProp;
  endclass
endpackage

module mod_home_top;
  import Pk_Homes::*;
  typedef struct packed { bit [1:0] mA; bit [6:0] mB; } modSpan_S;
  class ModHome;
    modSpan_S  d07_modProp;
    unitSpan_S d08_unitFromMod;
    pkgSpan_S  d09_pkgFromMod;
  endclass
  ModHome     inst_one;
  ModHome     inst_two;
  ModHome     inst_three;
  PkgDerived  inst_der;
  UnitHome    inst_unit;
endmodule
