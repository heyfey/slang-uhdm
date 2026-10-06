// § shadowedImportTsRefOwner260 (a for-generate continuous assignment's indexed part-select width)
package rp;
  localparam int OffD = 2;
endpackage
module ctrl import rp::*; (input logic [7:0] a, output logic [1:0] q [2]);
  localparam int OffD = 2;
  for (genvar i = 0; i < 2; i++) begin : g
    assign q[i] = a[i +: OffD];
  end
endmodule
module top;
  logic [7:0] a; logic [1:0] q [2];
  ctrl u (.a(a), .q(q));
endmodule
