// § moduleNamedClocking402
module top(input clk1, clk2, input a, b);
  clocking cba @(posedge clk1);
    input a;
  endclocking
  clocking cbb @(posedge clk2);
    input b;
  endclocking
endmodule
