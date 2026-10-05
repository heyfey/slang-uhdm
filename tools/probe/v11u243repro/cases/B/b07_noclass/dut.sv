// § unitImpPaRhsOwnCopy243
// a $unit import with no class: only the design's copies
package p;
  parameter A = 'hf000000;
  parameter int B = 4;
  parameter C = 5;
endpackage
import p::*;
module top;
  int x = A + B + C;
endmodule
