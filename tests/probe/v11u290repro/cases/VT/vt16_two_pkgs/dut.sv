// § pkgTdPackedDimsDefNetShares290
package p;
typedef logic [1:0] t;
endpackage
package r;
typedef logic [3:0] t;
endpackage
module top();
p::t [1:0] x;
r::t [2:0] y;
endmodule
