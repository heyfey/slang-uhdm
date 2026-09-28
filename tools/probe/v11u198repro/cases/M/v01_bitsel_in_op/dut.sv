// § methodArgOpRefChainName198
class C; int q[$]; int v; function int f(int k, int j = 0); return k + j; endfunction
  function C h(int k); return this; endfunction
  task t(int k); endtask endclass
class D;
  C c; int a[4];
  function int g(int n, int i);
    int x;
    x = c.f(a[i] + 1, n);
    return x;
  endfunction
endclass
module top; endmodule
