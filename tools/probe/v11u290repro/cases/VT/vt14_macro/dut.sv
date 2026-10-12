// § pkgTdPackedDimsDefNetShares290
`define DECL(n) p::t [2:0] n;
package p;
typedef logic [1:0] t;
endpackage
module top();
`DECL(x)
endmodule
