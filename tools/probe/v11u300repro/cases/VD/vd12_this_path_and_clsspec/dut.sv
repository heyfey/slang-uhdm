// § pkgRetCallFoldSharesCalleeRet300
package p;
  function int f (int a); return a + 1; endfunction
  class C #(int N = 2); int v [N]; function int m (int x); return this.v[f(x) % N]; endfunction endclass
  function int c (int x); return f(x); endfunction
endpackage
module top; p::C #(4) o; int r; logic [p::f(1):0] w; initial r = p::c(1) + w[p::c(0)]; endmodule
