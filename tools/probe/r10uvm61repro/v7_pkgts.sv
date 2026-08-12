// r10uvm61 VERIFIER ARM v7_pkgts — SHARPENING FINDING F1.  v1 showed golden
// KEEPS `$bits(m)` when the property is spelled `logic [PW-1:0] m` with PW a
// PACKAGE parameter, but FOLDS it when the same width arrives through a
// PACKAGE TYPEDEF.  This arm asks where the boundary actually runs:
//   * class-declared typedef whose bound reads a PACKAGE parameter
//   * package typedef whose bound reads a PACKAGE parameter (v1's folding row,
//     repeated here as the control)
//   * package packed STRUCT whose field width reads a package parameter
//   * a package parameter used with no arithmetic at all (`logic [PW:0]`)
//   * a package parameter reached through a LOCALPARAM of the same package
package v7_pkg;
  parameter int PW = 6;
  localparam int LW = PW;                      // pkg localparam OF a pkg param
  typedef logic [PW-1:0] pkg_dep_t;            // package typedef  (v1: FOLDS)
  typedef struct packed { logic [PW-1:0] a; logic [1:0] b; } pkg_st_t;

  class b_c;
    typedef logic [PW-1:0] cls_dep_t;          // CLASS typedef, PACKAGE bound
    logic [PW-1:0]  m_direct;   // R1 direct   (v1 measured: golden KEEPS)
    pkg_dep_t       m_pkgtd;    // R2 pkg typedef  (v1 measured: golden FOLDS)
    cls_dep_t       m_clstd;    // R3 CLASS typedef over a PACKAGE param  <-- ?
    pkg_st_t        m_pkgst;    // R4 pkg packed struct, pkg-param field   <-- ?
    logic [PW:0]    m_noarith;  // R5 pkg param, no arithmetic            <-- ?
    logic [LW-1:0]  m_vialp;    // R6 via a pkg LOCALPARAM of the param   <-- ?
    logic [3:0]     m_fix;      // R7 control: literal
    function void r1(ref int o);
      o = $bits(m_direct);
      o = $bits(m_pkgtd);
      o = $bits(m_clstd);
      o = $bits(m_pkgst);
      o = $bits(m_noarith);
      o = $bits(m_vialp);
      o = $bits(m_fix);
    endfunction
  endclass
endpackage

module v7_top;
  import v7_pkg::*;
  int o;
  initial begin
    b_c a = new();
    a.r1(o);
  end
endmodule
