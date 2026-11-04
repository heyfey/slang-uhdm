// § methodArgNestedRefChain201
class C; int q[$]; int v; function int f(int k, int j = 0); return k + j; endfunction
  function C h(int k); return this; endfunction
  task t(int k); endtask endclass
function automatic int g2(int a); return a; endfunction
class D;
  C c; int a[4]; int b[4][4];
  function int g(int n, int i, int j);
    int x;
    x = c.f(a[i] + 1, n);
    x = c.f(b[i][j] + 1);
    return x;
  endfunction
endclass
module top; endmodule
