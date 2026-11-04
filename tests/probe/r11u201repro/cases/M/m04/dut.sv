// § methodArgNestedRefChain201
class C; int q[$]; int v; function int f(int k, int j = 0); return k + j; endfunction
  function C h(int k); return this; endfunction
  task t(int k); endtask endclass
function automatic int g2(int a); return a; endfunction
class D;
  C c; int a[4];
  function int g(int i);
    return c.f(a[i]) + c.f(-a[i]);
  endfunction
endclass
module top; endmodule
