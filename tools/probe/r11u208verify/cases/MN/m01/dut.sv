// § methodArgNestedRefChain201
class E; function int h(int k); return k; endfunction endclass
class Dd; E e; function int g(int k); return k; endfunction endclass
class C; Dd d; function int f(int k, int j = 0); return k + j; endfunction endclass
module m01;
  C c;
  int a[4];
  int b[4][4];
  int i, j, x;
  function automatic int u(int z); return z; endfunction
  initial begin
    x = c.f(c.d.g(a[i] + 1));
    x = c.f(c.d.g(c.d.e.h(b[i][j]) + u(a[j])) - 1);
    x = c.f(a[u(i)] + b[i][u(j)]);
  end
endmodule
