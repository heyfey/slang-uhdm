// § defaultedStrPlaceholderRetry444
module m #(parameter w, lg = "inv") (input clk, input [w-1:0] a, output reg o);
  logic [23:0] c;
  logic [7:0] mem [logic [w-1:0]];
  always @(posedge clk) mem[a] <= 8'h0;
  always_comb begin
    o = 1'b0;
    if (c[23:lg] == 1'b1) o = 1'b1;
  end
endmodule
module top; endmodule
