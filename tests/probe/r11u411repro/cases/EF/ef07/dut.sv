// § enumSubstDecDecompile411
package p;
  typedef enum logic [2:0] { P = 3'd5, W } d_t;
endpackage
module top (input logic [2:0] x, output logic [2:0] o);
  assign o = p::P + x;
endmodule
