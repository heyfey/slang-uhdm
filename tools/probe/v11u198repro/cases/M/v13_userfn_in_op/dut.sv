// § methodArgOpRefChainName198
class C; int q[$]; int v; function int f(int k, int j = 0); return k + j; endfunction endclass
function automatic int g2(int a); return a; endfunction
class D;
  C c;
  function int g(int i);
    return c.f(g2(i) + 1);
  endfunction
endclass
module top; endmodule
