// § methodArgOpRefChainName198
class C; int q[$]; int v; function int f(int k, int j = 0); return k + j; endfunction endclass
class D;
  C c;
  task g(int i);
    int x;
    fork
      x = c.f(i + 2);
    join
  endtask
endclass
module top; endmodule
