// § pkgTdPackedDimsDefNetShares290
package p;
typedef logic [1:0] t;
endpackage
module top(output logic [3:0] o);
p::t [1:0] x;
assign x = 4'hA;
assign o = x;
endmodule
