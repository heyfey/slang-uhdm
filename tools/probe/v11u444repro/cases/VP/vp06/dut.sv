// § progLocalDeclNets444
program prg(input logic clk, output logic o);
int x;
task automatic t();
  int loc;
  loc = x;
  o = loc[0];
endtask
logic y;
initial t();
endprogram
