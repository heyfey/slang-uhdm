// § methodArgOpRefChainName198: operation arguments of a method call on a two-level path and on a chained call's result, a shift and a relational operand, in a task and a void function
class C; int q[$]; function int f(int k, int j = 0); return k + j; endfunction endclass
class E; C c; function C get(); return c; endfunction endclass
class D;
  E e; C c;
  task t(int n, int i);
    int x;
    x = e.c.f(i << 1, n);
  endtask
  function void v(int n, int i);
    int x;
    x = e.get().f(i + 1);
    x = c.f(n > i, i - n);
  endfunction
endclass
module top; endmodule
