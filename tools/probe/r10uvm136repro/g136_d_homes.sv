// r10uvm136 arm D — HOMES: $unit class, module class, package class, and
// 1..3 instances of the module home.
typedef struct packed { bit [6:0] uLow; bit [6:0] uHigh; } unit_range_UT;
typedef struct { int uu; } unit_loose_UT;

class UnitHome12;
  unit_range_UT d01_unitps;
  unit_loose_UT d02_unitus;
endclass

package Ph9;
  typedef struct packed { bit [2:0] pl; bit [2:0] ph; } pkg_range_PT;
  class PkgHome34;
    pkg_range_PT d03_pkgps;
  endclass
endpackage

module MHome(input logic clkIn);
  typedef struct packed { bit [3:0] ml; bit [3:0] mh; } mod_range_MT;
  class ModHome56;
    mod_range_MT d04_modps;
    unit_range_UT d05_unitFromMod;
  endclass
  ModHome56 mh;
  initial mh = new();
endmodule

module dtop;
  logic ck;
  MHome i_one(.clkIn(ck));
  MHome i_two(.clkIn(ck));
  MHome i_three(.clkIn(ck));
  UnitHome12 uh;
  Ph9::PkgHome34 ph;
  initial begin uh = new(); ph = new(); end
endmodule
