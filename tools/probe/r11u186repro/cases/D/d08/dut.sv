// § boundLitUnderscoreDropped186 (a packed and an unpacked bound, a typedef bound, a port bound)
package p;
  typedef logic [1_1:0] w_t;
endpackage
module top(input logic [2_3:0] a, output logic [2_3:0] o);
  logic [7:0] mem [0:1_0];
  p::w_t w;
  assign o = a;
endmodule
