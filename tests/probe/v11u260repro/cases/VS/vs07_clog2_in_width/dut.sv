// § shadowedImportTsRefOwner260 (the fold inside $clog2 inside an indexed part-select width)
package rp;
  localparam int OffD = 4;
endpackage
module ctrl import rp::*; (input logic [7:0] a, output logic [1:0] q);
  localparam int OffD = 4;
  always_comb q = a[0 +: $clog2(OffD)];
endmodule
module top;
  logic [7:0] a; logic [1:0] q;
  ctrl u (.a(a), .q(q));
endmodule
