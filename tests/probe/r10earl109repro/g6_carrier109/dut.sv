// r10earl109 arm g6 -- THE CARRIER matrix for the SAME written bound.
//
// `elabPortBoundScope109` is set around the WHOLE `makeTypespec` call for an
// elaborated port, so it is in flight for anything that call builds
// RECURSIVELY as well -- a struct member's own packed dimension, an unpacked
// dimension, a second packed dimension.  This arm puts the law's exact written
// bound (a bare `int` localparam of the port's own instance body) in every one
// of those positions and in every direction, so the grid says what golden wants
// there instead of leaving it to the corpus not to contain one.
// Every module here instantiates `g6_leaf109`, so `currentScope` is stale at
// every port-typespec build -- the corpus face, not the easy one.
// MEASUREMENT ONLY.  LHS is ALWAYS golden.
module g6_leaf109 (input logic a_i, output logic b_o);
  assign b_o = ~a_i;
endmodule

module g6_kid109 #(
  parameter  int MaxB109 = 64,
  localparam int W109    = 6      // int, 32-bit -- the law's parameter
) (
  input  logic                 clk_i,
  input  logic [W109:0]        c_in_i,        // INPUT   packed
  output logic [W109:0]        c_out_o,       // OUTPUT  packed
  inout  wire  [W109:0]        c_io_io,       // INOUT   packed
  input  logic [W109:0][1:0]   c_2d_i,        // TWO packed dimensions
  input  logic [1:0][W109:0]   c_2db_i,       // ...the other way round
  input  logic [W109:0]        c_unp_i [0:1], // packed + UNPACKED
  input  var logic [W109:0]    c_var_i,       // a VAR port, not a net
  output logic                 q_o
);
  logic lb;
  g6_leaf109 u_leaf (.a_i(clk_i), .b_o(lb));
  assign c_out_o = c_in_i;
  assign q_o = lb & c_io_io[0] & c_2d_i[0][0] & c_2db_i[0][0] &
               c_unp_i[0][0] & c_var_i[0];
endmodule

// A port TYPED BY A STRUCT whose MEMBER packed dimension is the law's own
// written bound.  The member typespec is built RECURSIVELY under the
// elaborated port's makeTypespec call, with the flag in flight, so this is
// the arm that says whether the law reaches through a named type.
// Non-ANSI ports, because the typedef has to be declared before it is used.
module g6_st109 (clk_i, sp_i, z_o);
  localparam int SW109 = 6;                 // int, 32-bit
  typedef struct packed { logic [SW109:0] m; logic t; } sp109_t;
  input  logic   clk_i;
  input  sp109_t sp_i;
  output logic   z_o;
  logic lb2;
  g6_leaf109 u_leaf2 (.a_i(clk_i), .b_o(lb2));
  assign z_o = lb2 & sp_i.m[0];
endmodule

module g6_carrier109;
  logic clk, q, z;
  logic [63:0] w;
  wire  [6:0]  io;
  logic [6:0]  unp [0:1];
  logic [7:0]  sp;
  g6_kid109 u_c (
    .clk_i(clk), .c_in_i(w), .c_out_o(), .c_io_io(io), .c_2d_i('0),
    .c_2db_i('0), .c_unp_i(unp), .c_var_i(w), .q_o(q));
  g6_st109 u_s (.clk_i(clk), .sp_i(sp), .z_o(z));
endmodule
