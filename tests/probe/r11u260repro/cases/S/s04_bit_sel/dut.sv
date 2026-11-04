// § shadowedImportTsRefOwner260 (a bit-select index)
package rp;
  localparam int OffD = 3;
endpackage
module ctrl import rp::*; (input logic [7:0] a, output logic q);
  localparam int OffD = 3;
  always_comb q = a[OffD];
endmodule
module top;
  logic [7:0] a; logic q;
  ctrl u (.a(a), .q(q));
endmodule
