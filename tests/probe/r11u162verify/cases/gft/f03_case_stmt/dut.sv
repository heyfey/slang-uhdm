// § genProcFoldTsKeepsScope154
module rs #(parameter int P = 2) (input clk, input [3:0] s, input [7:0] x, output reg [7:0] o);
  if (P > 0) begin : gb
    always @(posedge clk)
      case (s)
        4'd0: o[P-1:0] <= x[P-1:0];
        default: o <= x + P;
      endcase
  end
endmodule
module top(input clk, input [3:0] s, input [7:0] x, output [7:0] o); rs r(clk, s, x, o); endmodule
