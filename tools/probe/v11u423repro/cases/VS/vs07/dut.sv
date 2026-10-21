// § unszBasedPkgFoldUnsized423
package p;
  parameter X = 'hx;
  parameter Z = 'bz;
endpackage
module top(input logic [3:0] x, output logic [3:0] y, output logic [3:0] z);
  import p::*;
  assign y = x & X;
  assign z = x | Z;
endmodule
