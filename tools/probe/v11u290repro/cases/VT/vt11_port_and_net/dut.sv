// § pkgTdPackedDimsDefNetShares290
package p;
typedef logic [1:0] t;
endpackage
module sub(input p::t [3:0] a);
p::t [1:0] x;
endmodule
module top();
sub u(.a('0));
endmodule
