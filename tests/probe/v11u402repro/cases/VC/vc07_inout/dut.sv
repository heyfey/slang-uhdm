// § moduleNamedClocking402
module top(input clk, inout wire d);
  clocking cb @(posedge clk);
    inout d;
  endclocking
endmodule
