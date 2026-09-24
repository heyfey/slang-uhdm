// r10earl78 arm a3 — §W: the ABOVE-64 rule, the caLhsAdjustSize68 carve-outs
// reached from a GEN scope, and an INTERFACE gen scope.
// `ExprEval::get_value` sets invalidValue on a binary constant wider than 64
// bits (ExprEval.cpp:1967), so adjustSize's whole body is skipped and the
// producer's natural width survives whatever the Lhs is.
interface a3if;
  localparam int IW = 5;
  logic [1:0] if_nar;
  if (IW > 0) begin : gen_if
    assign if_nar = {IW{1'b1}};        // W1  INTERFACE body Lhs: no bind -> 5
  end
endinterface

module a3;
  localparam int W64 = 64;
  localparam int W65 = 65;
  localparam int W70 = 70;
  localparam int W6  = 6;
  logic [9:0]  w_64_10, w_65_10, w_70_10;
  logic [79:0] w_70_80;
  logic [63:0] w_64_64;
  logic [3:0]  fl_nar;
  real         r_lhs;
  var          bare_d;            // bare `var`: Surelog writes NO typespec
  logic [3:0]  arr [0:3];
  a3if u_if();

  if (W6 > 0) begin : gen_w
    assign w_64_10 = {W64{1'b1}};   // W2  natural 64 -> target 10  => 10
    assign w_64_64 = {W64{1'b1}};   // W3  natural 64 -> target 64  => 64
    assign w_65_10 = {W65{1'b1}};   // W4  natural 65 (>64) target 10 => 65
    assign w_70_10 = {W70{1'b1}};   // W5  natural 70 (>64) target 10 => 70
    assign w_70_80 = {W70{1'b1}};   // W6  natural 70 (>64) target 80 => 70
    assign r_lhs   = {W6{1'b1}};    // W7  a `real` Lhs
    assign bare_d  = {W6{1'b1}};    // W8  a bare `var` Lhs (no typespec)
    assign arr[1]  = {W6{1'b1}};    // W9  an unpacked-array ELEMENT Lhs
    assign impl_n  = {W6{1'b1}};    // W10 an IMPLICIT net Lhs
    assign fl_nar  = {W6{1'b1}};    // W11 plain module-body control -> 4
  end
endmodule
