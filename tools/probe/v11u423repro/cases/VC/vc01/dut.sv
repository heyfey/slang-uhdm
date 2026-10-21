// § caseItemPkgFoldTsLate423
package p;
  typedef bit [27:0] f_t;
  parameter f_t A = (1<<4);
  parameter f_t B = ~(1<<0);
endpackage
module top(input logic [27:0] x, output logic y);
  import p::*;
  always_comb begin
    case (x)
      A: y = 1'b0;
      B: y = 1'b1;
      default: y = 1'b0;
    endcase
  end
endmodule
