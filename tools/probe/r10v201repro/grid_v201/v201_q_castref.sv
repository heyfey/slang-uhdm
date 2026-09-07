// v201 arm Q — the ONE path where the def-view Lhs clone can carry a
// typespec while its own parameter does NOT: an UNSIZED-BASED untyped
// parameter whose NAME is a paren-cast width (implicitUnsizedBasedNoTs102
// declines `up->Typespec()`, isParenCastWidthParam still builds prtLhs9).
// Here it is reference-defaulted, copied into a module, an interface and a
// program, so the mint has every listing to fire in.
package p201vq;
  parameter Q_W  = 'h8;
  parameter Q_W2 = Q_W;
  parameter logic [31:0] Q_V  = (Q_W)'(3);
  parameter logic [31:0] Q_V2 = (Q_W2)'(5);
  parameter Q_D  = 'd13;
  parameter logic [31:0] Q_V3 = (Q_D)'(7);
endpackage
import p201vq::*;
interface i201vq;
endinterface
program pr201vq;
endprogram
module m201vq;
endmodule
