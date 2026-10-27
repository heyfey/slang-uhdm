// § portNameLocalNoTs444v
program prg(input logic clk, output int o);
int v;
task automatic t();
  int v;
  int clk;
  v = 1; clk = v;
  o = clk;
endtask
initial t();
endprogram
