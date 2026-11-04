// § progLocalDeclNets444
module top;
  logic clk;
endmodule
program prg;
int x;
task automatic t(); int loc; loc = x; endtask
initial t();
endprogram
