// § pkgElabUnaryFoldOpSpan274
package pk;
  parameter int W = -(-8);
  parameter int N = -(-2);
endpackage
module dut(input logic [15:0] x, output logic [7:0] o, output logic [15:0] r, output logic [3:0] q);
  logic [pk::W-1:0] v;
  assign v = x[pk::W-1:0];
  assign o = v;
  assign r = {pk::N{v}};
  assign q = x[pk::N +: 4];
endmodule
