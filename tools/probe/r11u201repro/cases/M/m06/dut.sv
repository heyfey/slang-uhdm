// § methodArgNestedRefChain201
class C; int q[$]; int v; function int f(int k, int j = 0); return k + j; endfunction
  function C h(int k); return this; endfunction
  task t(int k); endtask endclass
function automatic int g2(int a); return a; endfunction
class D;
  C c; int a[4];
  task tt(int i);
    c.t(a[i] + 1);
    c.t(g2(i) + 1);
  endtask
endclass
module top; endmodule
