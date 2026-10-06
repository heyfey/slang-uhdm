// § shareDefParamTsOwnNotImport262 (body localparam read in a case-generate block)
package rp;
  localparam int K = 2;
endpackage
module ctrl import rp::*; #(parameter int M = 1) (input logic [7:0] a, output logic [1:0] q);
  localparam int K = 2;
  case (M)
    1: begin : c1
      assign q = a[K +: 2];
    end
    default: begin : cd
      assign q = a[1:0];
    end
  endcase
endmodule
module top(input logic [7:0] a, output logic [1:0] q);
  ctrl u (.a(a), .q(q));
endmodule
