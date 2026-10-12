// § pkgTdPackedDimsDefNetShares290
package p;
typedef logic [1:0] t;
endpackage
module zmod();
if (1) begin : g
p::t [5:0][3:0] xg;
end
endmodule
module top();
p::t [1:0] x;
zmod u();
endmodule
