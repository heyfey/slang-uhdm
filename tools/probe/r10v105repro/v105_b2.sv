// r10v105 arm b2 — THE COLLISION GAP.  A typedef of the type parameter's
// SIMPLE NAME declared somewhere the implementer's guard does NOT walk:
// a MODULE, an INTERFACE, a PROGRAM and ANOTHER CLASS.  Surelog's
// ElaborationStep `specs` map is filled from EVERY component's typedef map
// (ElaborationStep.cpp:110-148), so golden repairs the placeholder from all of
// them.  MEASUREMENT ONLY.

package pmod_b2;
  class dm_b2; int mx; endclass
  class cmod_b2 #(type CMOD_B2 = dm_b2);
    extern function void f();
  endclass
  function void cmod_b2::f();
    CMOD_B2 xo_m;                 // collides with a typedef inside module tdmod_b2
  endfunction
endpackage

module tdmod_b2;
  typedef int CMOD_B2;            // the colliding typedef, in a MODULE
  int unused_b2;
endmodule

package pifc_b2;
  class di_b2; int ix; endclass
  class cifc_b2 #(type CIFC_B2 = di_b2);
    extern function void f();
  endclass
  function void cifc_b2::f();
    CIFC_B2 xo_i;                 // collides with a typedef inside an INTERFACE
  endfunction
endpackage

interface tdifc_b2;
  typedef int CIFC_B2;            // the colliding typedef, in an INTERFACE
endinterface

package pcls_b2;
  class dc_b2; int cx; endclass
  class other_b2;
    typedef int CCLS_B2;          // the colliding typedef, inside ANOTHER CLASS
    int ox;
  endclass
  class ccls_b2 #(type CCLS_B2 = dc_b2);
    extern function void f();
  endclass
  function void ccls_b2::f();
    CCLS_B2 xo_c;
  endfunction
endpackage

module topb2;
  import pmod_b2::*; import pifc_b2::*; import pcls_b2::*;
  tdmod_b2  u_mod();
  tdifc_b2  u_ifc();
  cmod_b2   h_m;
  cifc_b2   h_i;
  ccls_b2   h_c;
  other_b2  h_o;
  initial begin h_m = new(); h_i = new(); h_c = new(); h_o = new(); end
endmodule
