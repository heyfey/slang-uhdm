// § methodArgOpRefChainName198
package pq;
class C; int q[$]; int v; function int f(int k, int j = 0); return k + j; endfunction endclass
class D;
  C c;
  function int g(int i);
    return this.c.f(i - 1) + c.f(-i);
  endfunction
endclass
endpackage
module top; endmodule
