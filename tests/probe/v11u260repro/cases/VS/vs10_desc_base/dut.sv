// § shadowedImportTsRefOwner260 (a descending indexed part-select base in an always_ff)
package rp;
  localparam int OffD = 3;
endpackage
module ctrl import rp::*; (input logic clk, input logic [7:0] a, output logic [1:0] q);
  localparam int OffD = 3;
  always_ff @(posedge clk) q <= a[OffD -: 2];
endmodule
module top;
  logic clk; logic [7:0] a; logic [1:0] q;
  ctrl u (.clk(clk), .a(a), .q(q));
endmodule
