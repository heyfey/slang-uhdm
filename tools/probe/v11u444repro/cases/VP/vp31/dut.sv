// § progLocalDeclNets444
module top;
  logic clk;
  prg p(.clk(clk));
endmodule
program prg(input logic clk);
int cnt;
task automatic t();
  int loc;
  loc = cnt;
endtask
initial begin int b; t(); end
endprogram
