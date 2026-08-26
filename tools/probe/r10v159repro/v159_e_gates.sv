// v159 VERIFIER ARM E — THE GATES, ATTACKED.
//  E1  a MACRO that expands to a QUALIFIED read inside a class method: the code
//      gate is a rawText("::") test on the SOURCE RANGE, and a macro-written
//      qualified read is exactly the shape § psBoundPkgParamTs31's comment
//      warns a text test gets wrong.
//  E2  a class at COMPILATION-UNIT scope whose file-level import materialises
//      nothing into a package, while ANOTHER package materialises the SAME
//      parameter symbol -- the symbol-keyed map's cross-home exposure.
//  E3  a class LOCALPARAM / PARAMETER initialised from the import (inParamInit).
//  E4  a macro that expands to an UNQUALIFIED read (the positive control for E1).
// MEASUREMENT ONLY.
package vq159e_pkg;
  parameter int VE_A = 111;
  parameter int VE_B = 112;
  parameter int VE_C = 113;
endpackage

`define VE_QUAL  vq159e_pkg::VE_A
`define VE_BARE  VE_A

// a package that materialises VE_A/VE_B/VE_C for its OWN class
package vp159e_pkg;
  import vq159e_pkg::*;
  class vc159e;
    localparam LPE = VE_B + 1;          // E3a class localparam from the import
    int r;
    function void e1_macroqual();
      r = `VE_QUAL + 1;                 // E1  macro-written QUALIFIED
    endfunction
    function void e4_macrobare();
      r = `VE_BARE + 1;                 // E4  macro-written UNQUALIFIED
    endfunction
    function void e3_lp();
      r = LPE + 1;
    endfunction
  endclass
  class vc159ep #(int PE = VE_C + 1);   // E3b class parameter default
    int r;
    function void e3p();
      r = PE + 1;
    endfunction
  endclass
endpackage

// E2 : a class at COMPILATION-UNIT scope.  Its file-scope import materialises
// into no package at all, but vp159e_pkg above has already put VE_A in the
// symbol-keyed map.
import vq159e_pkg::*;
class vc159e2;
  int r;
  function void e2();
    r = VE_A + 1;
  endfunction
endclass

module vm159e;
  import vp159e_pkg::*;
  vc159e  h;
  vc159ep #(114) hp;
  vc159e2 h2;
  initial begin
    h = new(); hp = new(); h2 = new();
    h.e1_macroqual(); h.e4_macrobare(); h.e3_lp(); hp.e3p(); h2.e2();
  end
endmodule
