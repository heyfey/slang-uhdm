// § enumSubstDecDecompile411
package p;
  typedef enum logic [3:0] { P = 4'hA, W = 4'd3, B = 4'b0101 } d_t;
endpackage
module top (input logic [3:0] x, output logic o, output logic o2, output logic o3);
  assign o = (x == p::P);
  assign o2 = (x == p::W);
  assign o3 = (x == p::B);
endmodule
