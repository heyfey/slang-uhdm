// § pkgTdCloneBoundLoc134
// case b01: a package vector typedef whose bound is X*2-1, used in a module
package p;
  parameter int X = 3;
  typedef logic [X*2-1:0] t;
endpackage
module top(output logic [5:0] o);
  p::t v;
  assign v = '1;
  assign o = v;
endmodule
