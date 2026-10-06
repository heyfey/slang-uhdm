// § shadowedImportTsRefOwner260 (the fold as both bounds of one part select, and as an operand of the other bound)
package rp;
  localparam int OffD = 2;
endpackage
module ctrl import rp::*; (input logic clk, input logic [7:0] a, output logic q, output logic [1:0] r);
  localparam int OffD = 2;
  always_ff @(posedge clk) begin
    q <= a[OffD:OffD];
    r <= a[OffD+1:OffD];
  end
endmodule
module top;
  logic clk; logic [7:0] a; logic q; logic [1:0] r;
  ctrl u (.clk(clk), .a(a), .q(q), .r(r));
endmodule
