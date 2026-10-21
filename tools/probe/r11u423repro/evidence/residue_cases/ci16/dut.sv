// residue (no law landed): see README
package p;
  parameter A = 16;
  parameter B = (1<<2);
endpackage
import p::*;
module top(input int x, output logic [1:0] y);
  always_comb
    case (x)
      A: y = 0;
      B: y = 1;
      default: y = 1;
    endcase
endmodule
