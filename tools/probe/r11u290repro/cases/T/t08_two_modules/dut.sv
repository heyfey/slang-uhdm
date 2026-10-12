// § pkgTdPackedDimsDefNetShares290
package p;
typedef logic [1:0] t;
endpackage
module a();
p::t [1:0] xa;
endmodule
module top();
p::t [2:0][3:0] xb;
a u();
endmodule
