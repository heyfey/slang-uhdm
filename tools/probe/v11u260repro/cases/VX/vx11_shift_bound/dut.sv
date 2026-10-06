// § pkgSelPsBoundColonsElab260 (a shift and a parenthesised product in the bound, always_ff)
package cp;
  parameter logic [3:0][15:0] RC = {16'h1234, 16'h5678, 16'h9abc, 16'hdef0};
  parameter logic [1:0][3:0][15:0] R3 = '0;
endpackage
module m #(parameter int N = 2) (input logic clk, output logic [7:0] q);
  always_ff @(posedge clk) q <= cp::RC[2][((N*2) << 1)-1:0];
endmodule
module top;
  logic clk; logic [7:0] q;
  m u (.clk(clk), .q(q));
endmodule
