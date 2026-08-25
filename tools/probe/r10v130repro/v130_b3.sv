// r10v130repro/v130_b3.sv — VERIFIER ARM b3: the TOP-MODULE SHAPE grid.
// ONE package, ONE out-of-body method, SIX names read in a new[...] size
// argument — each name deliberately COLLIDING with a different declaration in
// the importing top module.  The question every cell asks: does the hoisted-net
// pool DUPLICATE, SHADOW or MINT where golden does not?
// MEASUREMENT ONLY.  LHS is ALWAYS golden; RHS is ALWAYS ours.
package pkColl130v;
  class cColl130v;
    int dynColl130v[];
    extern function void collRunner130v();
  endclass
  function void cColl130v::collRunner130v();
    int freshNameAlp130v;     // t01 the module declares NOTHING of this name
    int wireClashBet130v;     // t02 the module declares a WIRE of this name
    int paramClashGam130v;    // t03 the module declares a PARAMETER
    int lparamClashDel130v;   // t04 the module declares a LOCALPARAM
    int varClashEps130v;      // t05 the module declares an INT VARIABLE
    int regClashZet130v;      // t06 the module declares a LOGIC REG
    freshNameAlp130v   = 1;
    wireClashBet130v   = 2;
    paramClashGam130v  = 3;
    lparamClashDel130v = 4;
    varClashEps130v    = 5;
    regClashZet130v    = 6;
    dynColl130v = new[freshNameAlp130v];
    dynColl130v = new[wireClashBet130v];
    dynColl130v = new[paramClashGam130v];
    dynColl130v = new[lparamClashDel130v];
    dynColl130v = new[varClashEps130v];
    dynColl130v = new[regClashZet130v];
  endfunction
endpackage

import pkColl130v::*;

module topColl130v;
  wire wireClashBet130v;
  parameter int paramClashGam130v = 11;
  localparam int lparamClashDel130v = 12;
  int varClashEps130v;
  logic regClashZet130v;
  assign wireClashBet130v = 1'b0;
  initial begin
    cColl130v hColl130v;
    hColl130v = new();
    hColl130v.collRunner130v();
    varClashEps130v = paramClashGam130v + lparamClashDel130v;
    regClashZet130v = 1'b1;
  end
endmodule
