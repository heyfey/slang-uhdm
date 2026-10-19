// § pkgAliasCastTargetTs411
package p;
  typedef logic [7:0] b_t;
  parameter b_t P = 8'd44;
  parameter logic [3:0] Q = 4'd5;
endpackage
module top (output [7:0] o, output [3:0] q);
  assign o = p::P;
  assign q = p::Q;
endmodule
