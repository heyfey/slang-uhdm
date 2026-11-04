// § enumSubstDecLeadZero411v
package p;
  typedef enum logic [7:0] { P = 8'd1_0, W = 8'd007, E = 8'D9 } d_t;
endpackage
module top (input logic [7:0] x, output logic o);
  assign o = (x == p::P) || (x == p::W) || (x == p::E);
endmodule
