// § progLocalDeclNets444
program prg;
int x;
function automatic int f(int a);
  int s = a + 1;
  logic [3:0] q [2] = '{1, 2};
  static int cnt = 0;
  cnt++;
  return s + q[0];
endfunction
initial x = f(2);
endprogram
