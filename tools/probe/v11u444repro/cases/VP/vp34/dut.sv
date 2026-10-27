// § portNameLocalNoTs444v
program prg(input logic clk, output int o);
task automatic t();
  int clk;
  clk = 2;
  o = clk;
endtask
initial t();
endprogram
