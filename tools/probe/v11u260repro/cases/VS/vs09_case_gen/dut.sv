// § shadowedImportTsRefOwner260 (a case-generate scope's part-select bound)
package rp;
  localparam int OffD = 2;
endpackage
module ctrl import rp::*; #(parameter int K = 1) (input logic [7:0] a, output logic [2:0] q);
  localparam int OffD = 2;
  case (K)
    1: begin : c1 assign q = a[OffD:0]; end
    default: begin : cd assign q = '0; end
  endcase
endmodule
module top;
  logic [7:0] a; logic [2:0] q;
  ctrl u (.a(a), .q(q));
endmodule
