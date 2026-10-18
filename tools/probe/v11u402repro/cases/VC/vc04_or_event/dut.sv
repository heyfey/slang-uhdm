// § moduleNamedClocking402
module top(input clk, rst, input a);
  clocking cb @(posedge clk or negedge rst);
    input a;
  endclocking
endmodule
