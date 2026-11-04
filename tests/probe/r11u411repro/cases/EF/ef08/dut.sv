// § enumSubstDecDecompile411
package p;
  typedef enum { P = 7, W } d_t;
endpackage
module top (input logic [31:0] x, output logic o);
  assign o = (x == p::P);
endmodule
