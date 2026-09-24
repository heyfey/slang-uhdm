// § pkgTdCloneBoundLoc134
package p;
  parameter int W = 6;
  typedef logic [W-1:0] w_t;
  typedef logic [2*W-1:W] h_t;
endpackage
module top(input logic [5:0] i, output logic [5:0] o);
  import p::*;
  w_t a;
  h_t b;
  assign a = i;
  assign b = i;
  assign o = a ^ b;
endmodule
