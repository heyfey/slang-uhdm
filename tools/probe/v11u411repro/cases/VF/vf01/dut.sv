// § enumSubstDecDecompile411
package p;
  typedef enum logic [2:0] { P = 3'd2, W = 3'd5 } d_t;
endpackage
module top (input logic [2:0] x, output logic o);
  import p::*;
  assign o = (x == P) || (x == W);
endmodule
