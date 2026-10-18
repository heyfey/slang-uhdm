// § moduleNamedClocking402
module sub(input clk, input d);
clocking c2 @(negedge clk);
  input #2 d;
endclocking
endmodule
module top(input clk, input x); sub s(.clk(clk), .d(x)); endmodule
