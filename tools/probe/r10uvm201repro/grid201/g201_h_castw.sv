// r10uvm201 grid arm H — the § parenCastWidthLhsKeepsTs199v shape that MUST
// STAY: a package parameter used as a PAREN-CAST WIDTH, next to a control
// that reads it with plain arithmetic instead.
package p201h;
  parameter H_W = 'h8;
  parameter H_X = (H_W)'(3);
  parameter H_CTL = 'h8;
  parameter H_Y = H_CTL + 1;
endpackage
import p201h::*;
module m201h;
endmodule
