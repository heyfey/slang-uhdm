// § enumSubstDecDecompile411
package p;
  typedef enum logic [2:0] { P = 3'd0, W, E } d_t;
endpackage
module top (input logic [2:0] x, output logic o);
  assign o = (x == p::P);
endmodule
