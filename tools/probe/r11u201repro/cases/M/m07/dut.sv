// § methodArgNestedRefChain201
class C; int q[$]; int v; function int f(int k, int j = 0); return k + j; endfunction
  function C h(int k); return this; endfunction
  task t(int k); endtask endclass
function automatic int g2(int a); return a; endfunction
module top;
  C c; int a[4];
  function automatic int g(int i);
    return c.f(a[i] + 1) + c.f(g2(i) * 2);
  endfunction
  int r;
  initial r = c.f(a[r] + 1);
endmodule
