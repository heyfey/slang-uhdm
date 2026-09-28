// § methodArgOpRefChainName198
class C; int q[$]; int v; function int f(int k, int j = 0); return k + j; endfunction
  function C h(int k); return this; endfunction
  task t(int k); endtask endclass
class D;
  C c; int m;
  function int g(int i);
    return c.f(m + i);
  endfunction
endclass
module top; endmodule
