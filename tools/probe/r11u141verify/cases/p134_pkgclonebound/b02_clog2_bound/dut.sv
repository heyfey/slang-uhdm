// § pkgTdCloneBoundLoc134
// case b02: a package vector typedef whose bound is a $clog2 expression
package p;
  parameter int X = 16;
  typedef logic [$clog2(X)-1:0] t;
endpackage
module top(output logic [3:0] o);
  import p::*;
  t v;
  assign v = 4'd9;
  assign o = v;
endmodule
