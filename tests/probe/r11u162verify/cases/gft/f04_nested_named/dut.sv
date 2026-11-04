// § genProcFoldTsKeepsScope154
module rs #(parameter P = 4) (input clk, input [7:0] x, output [7:0] o);
  if (1) begin : ga
    if (P == 4) begin : gb
      reg [7:0] v;
      always @(posedge clk) v <= x + (P - 1);
      assign o = v;
    end
  end
endmodule
module top(input clk, input [7:0] x, output [7:0] o); rs r(clk, x, o); endmodule
