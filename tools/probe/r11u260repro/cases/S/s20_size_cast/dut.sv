// § shadowedImportTsRefOwner260 (a size cast)
package rp;
  localparam int OffD = 3;
endpackage
module ctrl import rp::*; (input logic [7:0] a, output logic [7:0] q);
  localparam int OffD = 3;
  always_comb q = 8'(OffD'(a));
endmodule
module top;
  logic [7:0] a, q;
  ctrl u (.a(a), .q(q));
endmodule
