// § enumSubstDecDecompile411
package p;
  typedef enum logic signed [3:0] { P = -4'sd3, W = 4'sd5 } d_t;
endpackage
module top (input logic signed [3:0] x, output logic o);
  assign o = (x == p::P) || (x == p::W);
endmodule
