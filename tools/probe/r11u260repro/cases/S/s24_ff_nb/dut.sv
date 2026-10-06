// § shadowedImportTsRefOwner260 (a nonblocking indexed part-select width in an always_ff)
package rp;
  localparam int OffD = 3;
endpackage
module ctrl import rp::*; (input logic [7:0] a, output logic [7:0] q);
  localparam int OffD = 3;
  logic c;
  always_ff @(posedge c) q <= {5'b0, ~a[2 +: OffD]};
endmodule
module top;
  logic [7:0] a, q;
  ctrl u (.a(a), .q(q));
endmodule
