// § defaultedStrPlaceholderRetry444
module ch #(parameter W = 4) (input [W-1:0] d); endmodule
module m #(parameter w, lg = "inv") (input clk, input [w-1:0] d, output reg o);
  logic [23:0] c;
  ch #(.W(lg)) u (.d(c));
  always_comb begin
    o = 1'b0;
    if (c[23:lg] == 1'b1) o = 1'b1;
  end
endmodule
module top; endmodule
