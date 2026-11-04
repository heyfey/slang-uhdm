// § pkgTdPackedDimsDefNetShares290
package p;
typedef logic [1:0] t;
endpackage
module top();
p::t [1:0] x;
endmodule
module lonely();
p::t [6:0][1:0] y;
endmodule
