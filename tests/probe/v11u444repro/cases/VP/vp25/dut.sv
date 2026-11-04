// § progLocalDeclNets444
program prg;
logic clk;
int x;
clocking cb @(posedge clk);
  input x;
endclocking
task automatic t(); int loc; @(cb); loc = x; endtask
initial t();
endprogram
