// § progLocalDeclNets444
program prg;
logic w;
assign w = 1'b1;
initial begin int a; a = w; end
logic y;
task automatic t(); int b; b = y; endtask
endprogram
