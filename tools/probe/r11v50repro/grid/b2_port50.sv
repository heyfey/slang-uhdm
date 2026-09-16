// r11v50 BREAK grid b2 — the ELAB PORT bound arm (call site 3,
// § elabPortIntBound109's encoding half) on a MODULE localparam whose
// initializer the reduce table and the `paramIntEnc` marker disagree on.
// Shape copied from the law's own corpus head (usbdev_usbif.sv:12-54):
// derived localparams in the PARAMETER PORT LIST, read as a port bound.
module ch52 #(
  parameter  int MaxA  = 64,
  localparam int D_LIT  = 12,
  localparam int D_MUL  = MaxA * 2,
  localparam int D_DIV  = MaxA / 8,
  localparam int D_SBAD = MaxA - 8 - 4 + 1,
  localparam int D_ADD  = MaxA + 8,
  localparam int D_CLOG = $clog2(MaxA),
  localparam int D_POW  = 2 ** 3,
  localparam int D_SHD  = (MaxA / 8) << 1,
  localparam int D_NEG  = 2 - 3,
  localparam int D_UMIN = -8 + 40,
  localparam int D_SUB  = MaxA - 8
) (
  input  logic clk,
  input  logic [D_LIT :0] p_lit,
  input  logic [D_MUL :0] p_mul,
  input  logic [D_DIV :0] p_div,
  input  logic [D_SBAD:0] p_sbad,
  input  logic [D_ADD :0] p_add,
  input  logic [D_CLOG:0] p_clog,
  input  logic [D_POW :0] p_pow,
  input  logic [D_SHD :0] p_shd,
  input  logic [D_UMIN:0] p_umin,
  input  logic [D_SUB :0] p_sub
);
  logic [D_MUL:0]  n_mul;
  logic [D_SBAD:0] n_sbad;
  logic [D_SHD:0]  n_shd;
  assign n_mul  = '0;
  assign n_sbad = '0;
  assign n_shd  = '0;
endmodule

module tb52;
  logic clk;
  logic [200:0] w;
  ch52 u (.clk(clk), .p_lit(w), .p_mul(w), .p_div(w), .p_sbad(w), .p_add(w),
          .p_clog(w), .p_pow(w), .p_shd(w), .p_umin(w), .p_sub(w));
endmodule
