// § genProcFoldTsKeepsScope154
module rs #(parameter P = 4) (input clk, input [7:0] x, output [7:0] o);
  reg [7:0] v;
  generate
    if (1) begin : gb
      always @(posedge clk) v[P-1:0] <= x[P-1:0];
    end
  endgenerate
  assign o = v;
endmodule
module top(input clk, input [7:0] x, output [7:0] o);
  rs r(clk, x, o);
endmodule
