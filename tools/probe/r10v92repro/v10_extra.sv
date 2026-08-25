// v92 adversarial arm 10 — shapes where reduceExpr REWRITES rather than
// returns the arm, plus a defparam'd condition and a nested-ternary condition.
module v10_leaf #(parameter bit EN = 1) (input logic [7:0] k, output logic [3:0] y);
  assign y = EN ? (k[5] ^ k[1]) : 4'h0;
endmodule

module v10_extra #(parameter bit EN = 1, parameter bit EN2 = 0, parameter int N = 1) (
    input  logic [7:0] k,
    input  logic       sig,
    output logic [3:0] y_lpsel,     // arm = bit_select of an unpacked localparam
    output logic [3:0] y_lpvsel,    // arm = var_select of a 2-D localparam
    output logic [3:0] y_terncond,  // condition = a nested ternary
    output logic [3:0] y_sysarm,    // arm = an ExprEval-implemented $ call
    output logic [3:0] y_dp,        // defparam'd instance
    output logic [3:0] y_signed,    // arm = $signed(sig-bearing expr)
    output logic [3:0] y_bitsel_nc  // arm = bit_select with a NON-constant index
);
  localparam logic [3:0] LPA [0:1]      = '{4'h3, 4'h5};
  localparam logic [3:0] LPB [0:1][0:1] = '{'{4'h1,4'h2},'{4'h3,4'h4}};
  logic [3:0] dy;
  v10_leaf u_dp (.k(k), .y(dy));
  assign y_lpsel     = EN ? LPA[1]            : 4'h0;
  assign y_lpvsel    = EN ? LPB[1][0]         : 4'h0;
  assign y_terncond  = (EN ? EN2 : 1'b1) ? (k[5] ^ k[2]) : 4'h0;
  assign y_sysarm    = EN ? $clog2(N + 8)     : 4'h0;
  assign y_dp        = dy;
  assign y_signed    = EN ? $signed({3'b0,sig}) : 4'h0;
  assign y_bitsel_nc = EN ? {3'b0, k[N]}      : 4'h0;
endmodule
