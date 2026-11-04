// § enumSubstDecDecompile411
package p;
  typedef enum int { P = 32'b0101, W = 32'hA, E = 'd7 } d_t;
endpackage
module top (input int x, output logic o);
  assign o = (x == p::P) || (x == p::W) || (x == p::E);
endmodule
