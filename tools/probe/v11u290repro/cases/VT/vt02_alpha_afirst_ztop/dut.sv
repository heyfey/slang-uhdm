// § pkgTdPackedDimsDefNetShares290
package p;
typedef logic [1:0] t;
endpackage
module amod();
p::t [5:0] xa;
endmodule
module bmod();
p::t [1:0][2:0] xb;
amod ua();
endmodule
