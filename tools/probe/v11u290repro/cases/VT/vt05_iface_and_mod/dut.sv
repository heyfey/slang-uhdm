// § pkgTdPackedWriterKindOrder290v
package p;
typedef logic [1:0] t;
endpackage
interface zif();
p::t [5:0][1:0] xi;
endinterface
module top();
p::t [1:0] x;
zif i();
endmodule
