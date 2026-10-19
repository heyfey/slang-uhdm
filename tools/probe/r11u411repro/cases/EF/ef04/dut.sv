// § enumSubstDecDecompile411
package p;
  typedef enum logic [3:0] { P = 4'hA, W = 4'd3 } d_t;
endpackage
module top (input logic [3:0] x, output logic o, output logic o2);
  import p::*;
  assign o = (x == P);
  assign o2 = (x == W);
endmodule
