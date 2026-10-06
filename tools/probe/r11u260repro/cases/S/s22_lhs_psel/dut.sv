// § shadowedImportTsRefOwner260 (a part-select bound on the left side)
package rp;
  localparam int OffD = 3;
endpackage
module ctrl import rp::*; (input logic [7:0] a, output logic [7:0] q);
  localparam int OffD = 3;
  always_comb begin q = '0; q[OffD:0] = a[3:0]; end
endmodule
module top;
  logic [7:0] a, q;
  ctrl u (.a(a), .q(q));
endmodule
