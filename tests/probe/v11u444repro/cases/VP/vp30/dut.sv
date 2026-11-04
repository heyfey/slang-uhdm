// § progLocalDeclNets444
program p1;
task automatic t(); int a; a = 1; endtask
initial t();
endprogram
program p2;
int a;
function automatic int f(); int a; a = 2; return a; endfunction
initial a = f();
endprogram
