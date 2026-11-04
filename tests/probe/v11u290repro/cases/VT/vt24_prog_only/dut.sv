// § pkgTdPackedWriterKindOrder290v
package p;
typedef logic [1:0] t;
endpackage
program bprog();
p::t [6:0] xb;
endprogram
program aprog();
p::t [4:0] xa;
endprogram
module top();
aprog a();
bprog b();
endmodule
