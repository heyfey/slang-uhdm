// § unitFwdCallNoLink403
module top;
  int r;
  initial r = g(2);
endmodule
function int g(int a);
  int t;
  t = f(a, 3);
  return t;
endfunction
function int f(int y, int z);
return y+z;
endfunction
