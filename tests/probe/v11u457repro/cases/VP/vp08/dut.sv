// § pkgRetCallPassArgShare457
function int rep(int v); return v; endfunction
function int f(int a);
  return rep(a);
endfunction
module top;
  int x;
  initial x = f(2);
endmodule
