// § pkgTdCloneBoundLoc134
package p;
  parameter int W = 6;
  typedef logic [W-1:0] w_t;
endpackage
module top(input logic [5:0] i, output logic [5:0] o);
  p::w_t a;
  assign a = i;
  assign o = a;
endmodule
