// § genProcFoldTsKeepsScope154
module rs #(parameter P = 4) (input clk, input [3:0] x, output [3:0] o);
  generate
    if (1) begin : gb
      reg [3:0] v;
      always @(posedge clk) v[P-1] <= x[0];
      assign o = v;
    end
  endgenerate
endmodule
module top(input clk, input [3:0] x, output [3:0] o);
  rs r(clk, x, o);
endmodule
