// § methodArgOpRefChainName198
class C; int q[$]; int v; function int f(int k, int j = 0); return k + j; endfunction
  function C h(int k); return this; endfunction
  task t(int k); endtask endclass
class D;
  C c;
  function int g(int i, int j);
    return c.f(i inside {j, 3});
  endfunction
endclass
module top; endmodule
