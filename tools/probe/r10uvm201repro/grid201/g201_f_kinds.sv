// r10uvm201 grid arm F — MODULE vs INTERFACE vs PROGRAM out of ONE file-scope
// import item.  The `defif` arm is why MiniAmiq (an interface_inst def
// listing) can be a mover.
package p201f;
  parameter F_BASE = 13;
  parameter F_REFU = F_BASE;
endpackage
import p201f::*;
module m201f;
endmodule
interface i201f;
endinterface
program pr201f;
endprogram
