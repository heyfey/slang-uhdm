// § progLocalDeclNets444
program prg;
import "DPI-C" function int c_f(int a);
int x;
function automatic int f(int a);
  int t1, t2 = 2, t3;
  t1 = c_f(a);
  return t1 + t2;
endfunction
initial x = f(1);
endprogram
