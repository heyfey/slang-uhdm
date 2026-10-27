// § defaultedStrPlaceholderRetry444
module m #(parameter w, lg = "inv") (input clk, output reg o);
  logic [23+w:0] c;
  for (genvar i = 0; i < 2; i++) begin : g
    always_comb if (c[23:lg+i] == 1'b1) o = 1'b1;
  end
endmodule
module top; endmodule
