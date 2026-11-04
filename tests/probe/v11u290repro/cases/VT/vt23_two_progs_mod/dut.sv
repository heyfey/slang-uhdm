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
module mid();
p::t [1:0] x;
endmodule
module top();
mid m();
aprog a();
bprog b();
endmodule
