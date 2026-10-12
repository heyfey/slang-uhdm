// § pkgTdPackedDimsDefNetShares290
package p;
typedef logic [1:0] t;
endpackage
package q;
p::t [3:0] pn;
endpackage
module top();
p::t [1:0] x;
endmodule
