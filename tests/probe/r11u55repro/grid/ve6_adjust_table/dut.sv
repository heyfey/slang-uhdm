// r11u55 ROAD E arm — THE adjustSize TABLE, read off golden rather than off
// the source.  `CompileHelper::adjustSize` (Surelog v1.87
// src/DesignCompile/CompileHelper.cpp:4065) branches on the constant's
// vpiConstType and on whether the new width is larger or smaller, and the
// branches are NOT symmetric (the vpiBinaryConst arm writes only when
// `orig_size > size`).  Every member below is read by a WHOLE-NAME Lhs that is
// narrower, equal and wider than the member, so each encoding is measured in
// both directions.  Members: UINT (plain decimal), HEX, BIN, and a based
// DECIMAL (vpiDecConst, which the `!= vpiDecConst` guard is supposed to
// exempt from resizing entirely).
package p;
  typedef struct packed {
    int unsigned u;       // 32, plain decimal -> UINT
    logic [15:0] h;       // 16, hex
    logic [15:0] b;       // 16, binary
    logic [15:0] d;       // 16, based decimal
  } cfg_t;
  localparam cfg_t LIT = '{u: 300,
                           h: 16'hBEEF,
                           b: 16'b1010_0101_1100_0011,
                           d: 16'd4660};
endpackage
module dut #(parameter p::cfg_t CFG = p::LIT)
           (output logic [7:0]  u_nar, output logic [31:0] u_eq,  output logic [63:0] u_wid,
            output logic [7:0]  h_nar, output logic [15:0] h_eq,  output logic [31:0] h_wid,
            output logic [7:0]  b_nar, output logic [15:0] b_eq,  output logic [31:0] b_wid,
            output logic [7:0]  d_nar, output logic [15:0] d_eq,  output logic [31:0] d_wid);
  assign u_nar = CFG.u;   assign u_eq = CFG.u;   assign u_wid = CFG.u;
  assign h_nar = CFG.h;   assign h_eq = CFG.h;   assign h_wid = CFG.h;
  assign b_nar = CFG.b;   assign b_eq = CFG.b;   assign b_wid = CFG.b;
  assign d_nar = CFG.d;   assign d_eq = CFG.d;   assign d_wid = CFG.d;
endmodule
