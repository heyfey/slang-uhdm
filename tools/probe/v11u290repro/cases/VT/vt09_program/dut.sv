// § pkgTdPackedWriterKindOrder290v
package p;
typedef logic [1:0] t;
endpackage
program zprog();
p::t [5:0] xp;
endprogram
module top();
p::t [1:0] x;
zprog pr();
endmodule
