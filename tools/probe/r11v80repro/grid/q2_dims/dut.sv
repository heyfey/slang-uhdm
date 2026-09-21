// v11u80 q2 -- THE FLATTENED vpiSize AND THE RANGE LIST.  r11u80 computes the
// PLAIN PRODUCT over the written declarator dimensions and claims the hoist
// site is NOT § fixedUnpackedCount6 (whose quirk makes a non-literal `[N]`
// dim contribute 1).  `z1_arrgrid` tested only `[2*2]`, a CONSTANT-FOLDED
// expression.  This arm asks the PARAMETER-sized dim, the localparam-sized
// dim, the mixed literal/param product, a size-style `[4]`, a descending
// `[7:4]`, a reversed `[0:0]`, a four-deep dim list, and a PACKED dim beside
// the unpacked ones.
package pq2;
  parameter  int PN = 3;
  localparam int LN = 5;
  typedef struct packed { logic [7:0] x; logic [7:0] y; } sl_t;

  logic [7:0] d_2d    [0:1][0:2];      // 6
  logic [7:0] d_3d    [0:1][0:2][0:3]; // 24
  logic [7:0] d_4d    [0:1][0:1][0:1][0:1]; // 16
  logic [7:0] d_desc  [7:4];           // 4
  logic [7:0] d_one   [0:0];           // 1
  logic [7:0] d_size  [4];             // 4
  logic [7:0] d_expr  [2*2];           // 4  (the implementer's face)
  logic [7:0] d_par   [PN];            // 3  <- PARAMETER-sized
  logic [7:0] d_lpar  [LN];            // 5  <- LOCALPARAM-sized
  logic [7:0] d_mix   [PN][0:1];       // 6  <- param x literal
  logic [7:0] d_parr  [PN-1:0];        // 3  <- param range
  logic [3:0][7:0] d_pk [0:1];         // packed dim + unpacked
  wire  [7:0] d_n2d   [0:1][0:2];      // NET side, two dims
  wire  sl_t  d_nsl2d [0:1][0:2];      // NET side, struct element, two dims
endpackage

module dut (output logic [31:0] o);
  import pq2::*;
  assign o = {24'd0, d_2d[0][0]} ^ {24'd0, d_3d[0][0][0]}
           ^ {24'd0, d_4d[0][0][0][0]} ^ {24'd0, d_desc[7]}
           ^ {24'd0, d_one[0]} ^ {24'd0, d_size[0]} ^ {24'd0, d_expr[0]}
           ^ {24'd0, d_par[0]} ^ {24'd0, d_lpar[0]} ^ {24'd0, d_mix[0][0]}
           ^ {24'd0, d_parr[0]} ^ d_pk[0]
           ^ {24'd0, d_n2d[0][0]} ^ {16'd0, d_nsl2d[0][0]};
endmodule
