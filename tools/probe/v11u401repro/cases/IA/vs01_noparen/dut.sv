// § intraAsgEventSpanInner401v
module top;
  logic clk, a, b;
  initial begin a = @clk b; a <= @(negedge clk) b; end
endmodule
