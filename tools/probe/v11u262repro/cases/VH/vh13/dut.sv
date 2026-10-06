// § shareDefParamTsOwnNotImport262 (no header list, the body localparam read inside a case-generate and as its selector)
package rp;
  localparam int K = 2;
endpackage
module ctrl import rp::*; (input logic [7:0] a, output logic [1:0] r);
  localparam int K = 2;
  case (K)
    2: begin : c2
      assign r = a[K +: 2];
    end
    default: begin : cd
      assign r = a[1:0];
    end
  endcase
endmodule
module top(input logic [7:0] a, output logic [1:0] r);
  ctrl u (.a(a), .r(r));
endmodule
