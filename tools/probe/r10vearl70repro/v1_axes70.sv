// r10vearl70 adversarial arm: vary spelling, symbol origin, bound position,
// generate nesting, and instance arrays for elaborated port high connections.
package va70_pkg;
  parameter int P = 16;
  localparam int L = 15;
  parameter int LO = 1;
  parameter int NEG = -2;
endpackage

module va70_leaf(
  input [63:0] a, b, c, d, e, f, g, h,
  input [7:0] arrp
);
endmodule

module va70_arrleaf(input [7:0] arrp);
endmodule

module va70_mid import va70_pkg::*; (input [127:0] sig);
  parameter int MP = 14;
  localparam int ML = 13;

  // Module-home controls: all package reads are supposed to reduce.
  va70_leaf u_mod(
    .a(sig[P-1:0]), .b(sig[63:P+1]),
    .c(sig[P:0]), .d(sig[63:P]),
    .e(sig[0 +: P]), .f(sig[P+1 +: 4]),
    .g(sig[va70_pkg::P-1:0]), .h(sig[MP-1:0]), .arrp(sig[7:0])
  );

  for (genvar i = 0; i < 2; i++) begin: gf
    // Left/right operation bounds should exercise the candidate; direct
    // bounds, indexed positions, qualified names, and module params refuse.
    va70_leaf u_for(
      .a(sig[P-1:0]), .b(sig[63:P+1]),
      .c(sig[P:0]), .d(sig[63:P]),
      .e(sig[0 +: P]), .f(sig[P+1 +: 4]),
      .g(sig[va70_pkg::P-1:0]), .h(sig[MP-1:0]), .arrp(sig[7:0])
    );
    va70_leaf u_local(
      .a(sig[L-1:0]), .b(sig[63:L+1]),
      .c(sig[L:0]), .d(sig[63:L]),
      .e(sig[0 +: L]), .f(sig[L+1 +: 4]),
      .g(sig[va70_pkg::L-1:0]), .h(sig[ML-1:0]), .arrp(sig[7:0])
    );
    // Legal two-element instance array: 16 bits divide across 2 x 8-bit ports.
    va70_arrleaf u_arr[1:0](.arrp(sig[P-1:0]));
  end

  if (1) begin: gi
    va70_leaf u_if(
      .a(sig[P-1:0]), .b(sig[63:P+1]),
      .c(sig[P:0]), .d(sig[63:P]),
      .e(sig[0 +: P]), .f(sig[P+1 +: 4]),
      .g(sig[va70_pkg::P-1:0]), .h(sig[MP-1:0]), .arrp(sig[7:0])
    );
  end

  case (1)
    1: begin: gc
      va70_leaf u_case(
        .a(sig[P-1:0]), .b(sig[63:P+1]),
        .c(sig[P:0]), .d(sig[63:P]),
        .e(sig[0 +: P]), .f(sig[P+1 +: 4]),
        .g(sig[va70_pkg::P-1:0]), .h(sig[MP-1:0]), .arrp(sig[7:0])
      );
    end
  endcase

  for (genvar j = 0; j < 2; j++) begin: go
    for (genvar k = 0; k < 2; k++) begin: gn
      va70_leaf u_nested(
        .a(sig[P-1:0]), .b(sig[63:P+1]),
        .c(sig[P:0]), .d(sig[63:P]),
        .e(sig[0 +: P]), .f(sig[P+1 +: 4]),
        .g(sig[va70_pkg::P-1:0]), .h(sig[MP-1:0]), .arrp(sig[7:0])
      );
    end
  end

  // Negative operation operand is a required refusal.
  for (genvar n = 0; n < 1; n++) begin: gneg
    va70_leaf u_neg(
      .a(sig[NEG+18-1:0]), .b(sig[63:NEG+3]),
      .c(sig[15:0]), .d(sig[63:1]), .e(sig[0 +: 16]),
      .f(sig[16 +: 4]), .g(sig[15:0]), .h(sig[13:0]), .arrp(sig[7:0])
    );
  end
endmodule

module va70_top(input [127:0] sig);
  va70_mid u(.sig(sig));
endmodule
