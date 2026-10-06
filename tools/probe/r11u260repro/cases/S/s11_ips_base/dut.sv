// § shadowedImportTsRefOwner260 (an indexed part-select base)
package rp;
  localparam int OffD = 2;
endpackage
module ctrl import rp::*; (input logic [7:0] a, output logic [1:0] q);
  localparam int OffD = 2;
  always_comb q = a[OffD +: 2];
endmodule
module top;
  logic [7:0] a; logic [1:0] q;
  ctrl u (.a(a), .q(q));
endmodule
