// § pkgTdPackedDimsDefNetShares290
package p;
typedef logic [1:0] t;
parameter int N = 4;
endpackage
module top #(parameter W = 3)();
p::t [W-1:0][p::N-1:0] x;
endmodule
