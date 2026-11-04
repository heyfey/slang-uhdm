// § pkgArrTdBindCopies250
package p;
  typedef logic [3:0] b_t[4];
endpackage
module top(input logic [3:0] i, output logic [3:0] o);
  import p::*;
  b_t m;
  assign m[0] = i;
  assign m[1] = m[0] + 1;
  assign o = m[1];
endmodule
