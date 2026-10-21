// residue (no law landed): see README
package p;
  typedef logic [7:0] f_t;
  parameter f_t A = 1 << 4;
  parameter f_t B = A + 1;
  parameter f_t C = (2 * 3) - 1;
  parameter f_t D = ~8'h0F;
endpackage
import p::*;
module top(input f_t x, output logic [1:0] y);
  always_comb
    case (x)
      A: y = 0;
      B: y = 1;
      C: y = 2;
      D: y = 3;
      default: y = 1;
    endcase
endmodule
