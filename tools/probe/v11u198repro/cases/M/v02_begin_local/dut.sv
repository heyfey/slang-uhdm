// § methodArgOpRefChainName198
class C; int q[$]; int v; function int f(int k, int j = 0); return k + j; endfunction
  function C h(int k); return this; endfunction
  task t(int k); endtask endclass
class D;
  C c;
  function int g(int n);
    int x;
    begin : blk
      int k;
      k = n;
      x = c.f(k + 1);
    end
    return x;
  endfunction
endclass
module top; endmodule
