// § shadowedImportTsRefOwner260 (a generate block's process)
package rp;
  localparam int OffD = 2;
endpackage
module ctrl import rp::*; (input logic [7:0] a, output logic [1:0] q);
  localparam int OffD = 2;
  if (1) begin : g
    always_comb q = a[1 +: OffD];
  end
endmodule
module top;
  logic [7:0] a; logic [1:0] q;
  ctrl u (.a(a), .q(q));
endmodule
