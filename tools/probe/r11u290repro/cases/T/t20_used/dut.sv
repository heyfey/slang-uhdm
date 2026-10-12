// § pkgTdPackedDimsDefNetShares290
package p;
typedef logic [1:0] t;
endpackage
module top(input logic [3:0] i, output logic [3:0] o);
p::t [1:0] x;
assign x = i;
assign o = x;
endmodule
