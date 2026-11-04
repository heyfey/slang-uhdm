// § moduleNamedClocking402
program prg(input clk, input a);
  clocking cb @(posedge clk);
    input a;
  endclocking
endprogram
module top(input clk, a);
  prg p(.clk(clk), .a(a));
endmodule
