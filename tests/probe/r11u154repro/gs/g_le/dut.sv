// § genProcFoldTsKeepsScope154
module rs #(parameter P = 3) (input clk, input [3:0] x, output [3:0] o);
  generate
    for (genvar g = 0; g < 1; g++) begin : gl
      reg [3:0] v;
      always @(posedge clk) v[P-1:0] <= x[P-1:0]; always @(posedge clk) v[P:0] <= 1;
      assign o = v;
    end
  endgenerate
endmodule
module top(input clk, input [3:0] x, output [3:0] o);
  rs r(clk, x, o);
endmodule
