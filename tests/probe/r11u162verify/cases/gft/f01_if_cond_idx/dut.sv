// § genProcFoldTsKeepsScope154
module rs #(parameter P = 3) (input clk, input [7:0] x, output reg o);
  if (1) begin : gb
    always @(posedge clk) if (x[P]) o <= x[P-1]; else o <= 1'b0;
  end
endmodule
module top(input clk, input [7:0] x, output o); rs r(clk, x, o); endmodule
