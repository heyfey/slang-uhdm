// § methodArgNestedRefChain201
package pk;
  class C; int q[$]; function int f(int k, int j = 0); return k + j; endfunction endclass
  class D;
    C c; int a[4]; logic [7:0] v;
    function int g(int i);
      return c.f(v[i+:2] + v[3:0]) + c.f(a[i]);
    endfunction
  endclass
endpackage
module top; endmodule
