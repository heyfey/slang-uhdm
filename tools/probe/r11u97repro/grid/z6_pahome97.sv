// r11u97 arm z6 — THE PARAMETER-PORT READING HOME, AND THE DEF/ELAB SPLIT
// OF A `BIN:` DECOMPILE.
//
// The wide boundary caught LAW C's first cut writing `<w>'b1` at the MODULE
// DEFINITION's `param_assign` where golden writes the BARE digit `1`
// (`r11v38repro/arms/v2_paenc.sv` 22:39 and `r11u38repro/grid/g2_paenc38.sv`
// 25:36): golden's `uhdmallModules` view decompiles a one-bit `BIN:` as `1`
// and every `uhdmtopModules` instance decompiles it as `<width>'b1`.  This
// arm holds that home on purpose, across declaration kinds, so the split is
// measured and not inferred.
package z6p;
  localparam int            CINT  = (3 < 4);
  localparam                CIMP  = (3 < 4);
  localparam logic [31:0]   CL32  = (3 < 4);
  localparam int            CINTF = (4 < 3);
  localparam int            CSUB  = 8 - 1;      // the landed minus law
  localparam int            CMULX = 2 * 3 + 1;  // LAW B
endpackage
module z6_sub #(
    parameter int          P_CINT  = z6p::CINT,
    parameter              P_CIMP  = z6p::CIMP,
    parameter logic [31:0] P_CL32  = z6p::CL32,
    parameter int          P_CINTF = z6p::CINTF,
    parameter int          P_CSUB  = z6p::CSUB,
    parameter int          P_CMULX = z6p::CMULX
) (output logic [31:0] q);
  localparam int L_CINT = z6p::CINT;
  assign q = P_CINT + P_CIMP + P_CL32 + P_CINTF + P_CSUB + P_CMULX + L_CINT;
endmodule
module z6_pahome97 (output logic [63:0] o);
  wire [31:0] q0, q1;
  z6_sub u0 (.q(q0));
  z6_sub #(.P_CINT(z6p::CINT)) u1 (.q(q1));
  wire signed [31:0] wCINT  = z6p::CINT;
  wire signed [31:0] wCIMP  = z6p::CIMP;
  wire signed [31:0] wCL32  = z6p::CL32;
  wire signed [31:0] wCINTF = z6p::CINTF;
  assign o = {q0, q1} ^ {wCINT, wCIMP} ^ {wCL32, wCINTF};
endmodule
