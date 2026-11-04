// § methodArgNestedRefChain201
package pk;
  class N;
    function int f(int v); return v; endfunction
  endclass
  function automatic int g(N c, int a[4], int i);
    return c.f(a[i] + 1) + c.f(a[i+1]);
  endfunction
endpackage
module top;
  import pk::*;
  N n;
  int a[4];
  int r;
  initial begin n = new; r = g(n, a, 1); r = n.f(a[r] * 2); end
endmodule
