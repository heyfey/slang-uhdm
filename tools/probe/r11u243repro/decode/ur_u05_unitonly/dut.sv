// § unitImpPaRhsOwnCopy243
// a $unit import with no class: the design's own param_assign copies
package q;
  parameter R = 'hf;
  parameter W = 8;
  parameter string N = "n";
endpackage
import q::*;
module top;
  int x;
  initial x = W;
endmodule
