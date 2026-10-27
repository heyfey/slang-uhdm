// § progLocalDeclNets444
program prg;
task automatic t(); int a; a = 1; endtask
function automatic int f(); int b; b = 2; return b; endfunction
final begin int c; c = f(); end
initial begin int d; t(); end
endprogram
