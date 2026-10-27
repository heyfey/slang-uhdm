// § progLocalDeclNets444
program prg;
int x;
function automatic int f(input int a);
  int s = 0;
  static int st;
  s = a + st;
  return s;
endfunction
initial x = f(1);
endprogram
