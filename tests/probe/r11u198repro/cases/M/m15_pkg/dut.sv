// § methodArgOpRefChainName198
package pk;
class C; int q[$]; function int f(int k, int j = 0); return k + j; endfunction
  task t(int k); endtask endclass
class D; C c;
  function int g(int n, int i); return c.f(n, i + 1); endfunction
endclass
endpackage
module top; endmodule
