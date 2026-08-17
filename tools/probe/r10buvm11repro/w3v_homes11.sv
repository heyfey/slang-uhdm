// r10buvm11 arm w3 — THE HOME GRID: the same three shapes (2-D leading assoc,
// 1-D assoc control, fixed control) at every scope a variable can live in, in
// BOTH the DEF and the ELAB view.  MEASUREMENT ONLY.
class w3_ucls;                      // a class at $unit scope
  bit u_aa [int][int];
  bit u_a1 [int];
  bit u_f  [4];
endclass
package pk11c;
  bit p_aa [int][int];              // a PACKAGE-scope variable
  bit p_a1 [int];
  bit p_f  [4];
  class w3_pcls;                    // a class in a package
    bit c_aa [int][int];
    bit c_a1 [int];
    bit c_f  [4];
  endclass
  function automatic int pf11();    // a package FUNCTION local
    bit fl_aa [int][int];
    bit fl_a1 [int];
    bit fl_f  [4];
    fl_aa[0][0] = 1'b1;
    fl_a1[0]   = 1'b1;
    fl_f[0]    = 1'b1;
    return 0;
  endfunction
endpackage
module w3v_homes11_top;
  bit m_aa [int][int];              // a MODULE-scope variable
  bit m_a1 [int];
  bit m_f  [4];
  class w3_mcls;                    // a class in a module
    bit mc_aa [int][int];
    bit mc_a1 [int];
    bit mc_f  [4];
  endclass
  w3_mcls    mu = new();
  pk11c::w3_pcls pu = new();
  w3_ucls    uu = new();
  int        r;
  function automatic int mf11();    // a module FUNCTION local
    bit mfl_aa [int][int];
    bit mfl_a1 [int];
    bit mfl_f  [4];
    mfl_aa[0][0] = 1'b1;
    mfl_a1[0]    = 1'b1;
    mfl_f[0]     = 1'b1;
    return 0;
  endfunction
  initial begin : blk11              // a named BLOCK local
    bit bl_aa [int][int];
    bit bl_a1 [int];
    bit bl_f  [4];
    bl_aa[0][0] = 1'b1;
    bl_a1[0]    = 1'b1;
    bl_f[0]     = 1'b1;
    r = mf11() + pk11c::pf11();
  end
endmodule
