// § methodArgOpRefChainName198
class C; int q[$]; int v; function int f(int k, int j = 0); return k + j; endfunction
  function C h(int k); return this; endfunction
  task t(int k); endtask endclass
module top;
  C c;
  int r;
  function automatic int g(int i);
    return c.f(i << 1);
  endfunction
  initial begin
    int k;
    c = new;
    k = 3;
    r = c.f(k + 2) + g(k);
  end
endmodule
