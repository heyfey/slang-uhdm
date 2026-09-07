// r10uvm188 — ARM b: the SAME shift shape in five HOMES.
// package / class / module / interface / a package IMPORTED into a module (the
// clone listing).  The listing a home produces is what decides whether the
// def-view render or the folded one is the one the judge reads.
package bsc;
  typedef enum { bP_a = 1 << 3, bP_b = 7 + 2, bP_c = 5 } bsc_pkg_e;
  class BscCls;
    typedef enum { bC_a = 1 << 3, bC_b = 7 + 2, bC_c = 5 } bsc_cls_e;
    bsc_cls_e h;
  endclass
endpackage
module bmod;
  typedef enum { bM_a = 1 << 3, bM_b = 7 + 2, bM_c = 5 } bsc_mod_e;
  bsc_mod_e q;
  initial q = bM_a;
endmodule
interface bifc;
  typedef enum { bI_a = 1 << 3, bI_b = 7 + 2, bI_c = 5 } bsc_ifc_e;
  bsc_ifc_e r;
endinterface
module bimp;
  import bsc::*;
  bsc_pkg_e s;
  initial s = bP_a;
endmodule
module bTop;
  bmod u0(); bifc u1(); bimp u2();
endmodule
