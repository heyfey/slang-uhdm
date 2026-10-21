// § unszPkgFoldElabForm425
package p;
  parameter H = 'd200;
  parameter O = 'o17;
  parameter Z = 'd0;
  parameter BIG = 'd3000000000;
endpackage
module top(input logic clk, input logic [7:0] a);
  assert property (@(posedge clk) a != p::H);
  always @(posedge clk) assert (a < p::O + 8'd1);
endmodule
