// g7 — THE >64-BIT WIDTH face at the import-copy face: a wide PACKED struct
// never read (elab package TAGGED) beside one the package member-selects
// (member select OUTRANKS width -> elab package FLAT).
package p7;
  typedef struct packed { logic [31:0] a; logic [31:0] b; logic [31:0] c; } w7_t;
  localparam w7_t WNON = '{a: 32'd1, b: 32'd2, c: 32'd3};
  localparam w7_t WSEL = '{a: 32'd4, b: 32'd5, c: 32'd6};
  typedef logic [WSEL.a-1:0] w1_t;
endpackage

module g7q import p7::*; (input logic clk);
  w1_t d;
  assign d = '0;
endmodule

module g7top(input logic clk);
  g7q u_q (.clk(clk));
endmodule
