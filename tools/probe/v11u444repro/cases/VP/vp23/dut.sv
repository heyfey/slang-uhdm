// § progLocalDeclNets444
program prg;
assign imp = 1'b1;
int x;
task automatic t(); int loc; loc = x; endtask
logic y;
initial t();
endprogram
