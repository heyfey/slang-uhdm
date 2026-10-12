// § pkgTdPackedWriterKindOrder290v
package p;
typedef logic [1:0] t;
endpackage
module aa();
p::t [1:0] x;
zif i();
endmodule
interface zif();
p::t [5:0][1:0] xi;
endinterface
