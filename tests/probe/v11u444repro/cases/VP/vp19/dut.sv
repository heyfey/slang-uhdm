// § progLocalDeclNets444
program prg;
task automatic t();
  int b;
  b = 1;
endtask
int a;
function automatic int f(); int c; c = a; return c; endfunction
int d;
initial begin int e; e = f(); t(); end
endprogram
