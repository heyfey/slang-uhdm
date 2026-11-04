// § progLocalDeclNets444
program prg;
int x;
function automatic int f();
  return x;
endfunction
task automatic t(input int a, ref int r);
  r = a;
endtask
initial t(f(), x);
endprogram
