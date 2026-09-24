// § pkgTdCloneBoundLoc134
// case b03: a package vector typedef with both bounds computed
package p;
  parameter int HI = 9;
  parameter int LO = 2;
  typedef logic [HI-1:LO+1] t;
endpackage
module top(output logic [4:0] o);
  p::t v;
  assign v = 5'h11;
  assign o = v;
endmodule
