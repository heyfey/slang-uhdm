// § shadowedImportTsRefOwner260 (a ternary in an indexed part-select width)
package rp;
  localparam int OffD = 3;
endpackage
module ctrl import rp::*; (input logic [7:0] a, output logic [7:0] q);
  localparam int OffD = 3;
  always_comb q = {6'b0, a[1 +: ((OffD > 2) ? 2 : 1)]};
endmodule
module top;
  logic [7:0] a, q;
  ctrl u (.a(a), .q(q));
endmodule
