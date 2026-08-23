// r10v105 arm b5 — the GUARD's own edges.  MEASUREMENT ONLY.
//  * a $unit-homed class whose parameter name collides with a typedef in an
//    UNRELATED PACKAGE (Surelog's repair loops iterate PACKAGE / MODULE / CLASS
//    definitions' late-binding lists -- a $unit component is in NONE of them,
//    so golden should NOT repair, while the guard's package walk suppresses).
//  * an OUT-OF-BODY CONSTRUCTOR with a parameter-typed local.
//  * a colliding typedef declared AFTER the class in the same package.
//  * the same parameter used out of body in a class the package EXPORTS to an
//    importing package.

package far_b5;
  typedef int UB5FAR;                 // the far typedef, package-homed
  typedef int LATE_B5;
endpackage

class dun_b5; int ux; endclass
class cun_b5 #(type UB5FAR = dun_b5);
  extern function void uf();
endclass
function void cun_b5::uf();
  UB5FAR uo_far;                      // $unit home + a FAR package typedef
endfunction

package ctor_b5;
  class dctor_b5; int cx; endclass
  class cctor_b5 #(type CT = dctor_b5);
    extern function new();
    extern function void m();
  endclass
  function cctor_b5::new();
    CT ctor_l;                        // OUT-OF-BODY CONSTRUCTOR body local
  endfunction
  function void cctor_b5::m();
    CT meth_l;
  endfunction
endpackage

package late_b5;
  class dlate_b5; int lx; endclass
  class clate_b5 #(type LATE_B5 = dlate_b5);
    extern function void lf();
  endclass
  function void clate_b5::lf();
    LATE_B5 late_l;                   // collides with far_b5::LATE_B5 (not imported)
  endfunction
  typedef int LATE_B5_OTHER;
endpackage

package prod_b5;
  class dprod_b5; int px; endclass
  class cprod_b5 #(type PT = dprod_b5);
    extern function void pf();
  endclass
  function void cprod_b5::pf();
    PT prod_l;
  endfunction
endpackage

package cons_b5;
  import prod_b5::*;
  export prod_b5::*;
  class user_b5;
    cprod_b5 h;
    function new(); h = new(); endfunction
  endclass
endpackage

module topb5;
  import ctor_b5::*; import late_b5::*; import cons_b5::*; import far_b5::*;
  cun_b5   h_u;
  cctor_b5 h_c;
  clate_b5 h_l;
  user_b5  h_p;
  initial begin h_u = new(); h_c = new(); h_l = new(); h_p = new(); end
endmodule
