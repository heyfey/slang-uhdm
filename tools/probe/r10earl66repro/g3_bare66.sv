// r10earl66 GRID ARM 3 — the BARE ACTUAL, the one position the Scr1SvTests
// regression exposed: `.p(EH4)` with NOTHING around the enum name, contrasted
// with `.p(32'(EH4))` (a cast, which golden folds) and with a bare PARAMETER /
// bare NET actual.  Also: the enum-typed formal vs an integral formal.
// MEASUREMENT ONLY.
package pb66;
  typedef enum logic [2:0] { BH0 = 3'h0, BH4 = 3'h4 } bh_e;
  localparam int BLP = 5;
endpackage

module leafb66 import pb66::*; (
  input  bh_e         e_i,      // ENUM-TYPED formal
  input  logic [31:0] a_i,      // integral formal
  input  logic [2:0]  n_i,
  output logic        o_o
);
  assign o_o = ^a_i ^ ^n_i ^ ^e_i;
endmodule

module g3_bare66 import pb66::*; (
  input  logic [63:0] d_i,
  output logic [7:0]  o_o
);
  logic [2:0] w3;
  assign w3 = d_i[2:0];

  // BARE enum-constant actual, enum-typed formal
  leafb66 u_bare_e (.e_i(BH4), .a_i(32'b0), .n_i(w3), .o_o(o_o[0]));
  // BARE enum-constant actual, INTEGRAL formal
  leafb66 u_bare_n (.e_i(BH0), .a_i(32'b0), .n_i(BH4), .o_o(o_o[1]));
  // BARE enum-constant actual, WIDE integral formal
  leafb66 u_bare_a (.e_i(BH0), .a_i(BH4),   .n_i(w3), .o_o(o_o[2]));
  // CAST around the same read (the arm-1 shape that folds)
  leafb66 u_cast   (.e_i(BH0), .a_i(32'(BH4)), .n_i(w3), .o_o(o_o[3]));
  // BARE package LOCALPARAM actual (the earl64 twin)
  leafb66 u_bare_p (.e_i(BH0), .a_i(32'b0), .n_i(3'(BLP)), .o_o(o_o[4]));
  // a bit-select index (the head's own shape) as the positive control
  leafb66 u_idx    (.e_i(BH0), .a_i(32'(d_i[BH4])), .n_i(w3), .o_o(o_o[5]));
  // BARE enum actual in a gen-for and a gen-if home
  for (genvar i = 0; i < 1; i++) begin : gen_for
    leafb66 u_gf (.e_i(BH4), .a_i(32'b0), .n_i(w3), .o_o(o_o[6]));
  end
  if (1) begin : gen_if
    leafb66 u_gi (.e_i(BH4), .a_i(32'b0), .n_i(w3), .o_o(o_o[7]));
  end
endmodule
