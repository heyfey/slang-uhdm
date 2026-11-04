// § impPatMemberReadParentsAll252
package p;
  typedef struct packed { int a; int b; } s_t;
  localparam s_t O = '{a : 3, b : 0};
  localparam int X = O.a + 1;
endpackage
module top import p::*; (input logic [7:0] x, output logic y);
  always_comb case (x) O.a: y = 1; default: y = 0; endcase
endmodule
