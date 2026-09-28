// § methodArgOpRefChainName198
class C; function int f(int k, int j = 0); return k + j; endfunction endclass
module top (input int a, output int y);
  C c; C arr[4];
  function automatic int g(int n, int i);
    return c.f((n + i) * 2);
  endfunction
  assign y = g(a, 1);
endmodule
