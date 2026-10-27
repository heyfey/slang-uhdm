// § progLocalDeclNets444
program prg(input logic clk);
int x;
task automatic t(input int a);
  int loc;
  loc = a;
  x = loc;
endtask
initial t(1);
endprogram
module top;
  logic clk;
  prg p(.clk(clk));
endmodule
