// § pkgTdPackedWriterKindOrder290v
package p;
typedef logic [1:0] t;
endpackage
interface aif();
p::t [3:0] xi;
endinterface
program zprog();
p::t [6:0] xp;
endprogram
module top();
aif i();
zprog pr();
endmodule
