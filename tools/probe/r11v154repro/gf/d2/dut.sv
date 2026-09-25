// § genProcFoldTsKeepsScope154
module rs #(parameter P = 4) (input clk, input [7:0] x, output [7:0] o);
  generate
    for (genvar g = 0; g < 2; g++) begin : gl
      reg [7:0] v;
      always @(posedge clk) v[P*g +: P] <= x[P-1:0];
      if (g == 1) begin : inner
        always @(posedge clk) v[2*P-1] <= x[P];
      end
    end
  endgenerate
  assign o = gl[0].v;
endmodule
module top(input clk, input [7:0] x, output [7:0] o);
  rs #(3) r(clk, x, o);
endmodule
