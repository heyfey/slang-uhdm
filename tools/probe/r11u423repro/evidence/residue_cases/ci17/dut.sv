// residue (no law landed): see README
package p;
  typedef bit [27:0] f_t;
  parameter f_t A = (1<<4);
endpackage
import p::*;
module top(input f_t x, output logic [1:0] y);
  always_comb
    case (x)
      A: y = 0;
      default: y = 1;
    endcase
endmodule
