// v82 adversarial arm V7 — EDGES of the declaration-side encoder: a NEGATIVE
// package parameter at a bound (pkgBoundValueConst9 renders the value with
// toString(Decimal, /*signed=*/false)), a >64-bit package parameter, a signed
// one, a parameter whose value is 0, and the same names on a NET and a VAR.
// MEASUREMENT ONLY.
package pkv7_82;
  localparam int          PNEG  = -1;
  localparam logic [99:0] PWIDE = 8;
  localparam int          PZERO = 0;
  localparam bit signed [7:0] PSGN = 8;
endpackage

typedef struct packed { logic [3:0] a; } mv7_t;

module top_v7_82 import pkv7_82::*; (input logic clk, output logic o);
  mv7_t [PNEG:0]  v_neg;
  mv7_t [PWIDE:0] v_wide;
  mv7_t [PZERO:0] v_zero;
  mv7_t [PSGN:0]  v_sgn;
  wire  mv7_t [PWIDE:0] w_wide;
  logic [PWIDE:0] n_wide;
  logic [PSGN:0]  n_sgn;
  assign o = clk ^ v_neg[0].a[0] ^ v_wide[0].a[0] ^ v_zero[0].a[0]
             ^ v_sgn[0].a[0] ^ w_wide[0].a[0] ^ n_wide[0] ^ n_sgn[0];
endmodule
