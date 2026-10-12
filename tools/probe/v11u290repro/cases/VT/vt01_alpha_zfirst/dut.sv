// § pkgTdPackedDimsDefNetShares290
package p;
typedef logic [1:0] t;
endpackage
module zmod();
p::t [3:0][1:0] xz;
endmodule
module amod();
p::t [1:0] xa;
endmodule
module top();
zmod uz();
amod ua();
endmodule
