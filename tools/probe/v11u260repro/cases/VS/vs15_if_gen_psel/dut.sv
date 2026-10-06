// § shadowedImportTsRefOwner260 (an if-generate continuous assignment, the indexed part-select width)
package rp;
  localparam int OffD = 2;
endpackage
module ctrl import rp::*; #(parameter bit E = 1) (input logic [7:0] a, output logic [1:0] q);
  localparam int OffD = 2;
  if (E) begin : g
    assign q = a[4 +: OffD];
  end else begin : h
    assign q = '0;
  end
endmodule
module top;
  logic [7:0] a; logic [1:0] q;
  ctrl u (.a(a), .q(q));
endmodule
