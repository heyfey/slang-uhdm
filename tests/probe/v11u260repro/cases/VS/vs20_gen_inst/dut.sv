// § shadowedImportTsRefOwner260 (the shadowing module instantiated inside a for-generate, two copies)
package rp;
  localparam int OffD = 2;
endpackage
module ctrl import rp::*; (input logic [7:0] a, output logic [1:0] q);
  localparam int OffD = 2;
  assign q = a[3 +: OffD];
endmodule
module top;
  logic [7:0] a; logic [1:0] q [2];
  for (genvar i = 0; i < 2; i++) begin : g
    ctrl u (.a(a), .q(q[i]));
  end
endmodule
