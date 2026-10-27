// § defaultedStrPlaceholderRetry444
module m #(parameter w, lg = "inv") (input clk, output reg o, output [w-1:0] z);
  localparam k = lg;
  logic [23:0] c;
  assign z = '0;
  always_comb begin
    o = 1'b0;
    if (c[23:k] == 1'b1) o = 1'b1;
  end
endmodule
module top; endmodule
