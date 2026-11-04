// § shadowedImportTsRefOwner260 (an indexed part-select width in a for loop of an always_comb, the base an operation)
package rp;
  localparam int OffD = 2;
endpackage
module ctrl import rp::*; (input logic [7:0] a, output logic [3:0] q);
  localparam int OffD = 2;
  always_comb begin
    q = '0;
    for (int i = 0; i < 4; i++) q[i] = ^a[i*OffD +: OffD];
  end
endmodule
module top;
  logic [7:0] a; logic [3:0] q;
  ctrl u (.a(a), .q(q));
endmodule
