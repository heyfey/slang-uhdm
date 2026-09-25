// § genProcFoldTsKeepsScope154
module rs (input clk, input [7:0] x, output [7:0] o);
  for (genvar g = 0; g < 2; g++) begin : gl
    localparam int Q = 2 + g;
    reg [7:0] v;
    always @(posedge clk) v[Q-1:0] <= x[Q-1:0];
    assign o[g] = v[0];
  end
endmodule
module top(input clk, input [7:0] x, output [7:0] o); rs r(clk, x, o); endmodule
