// § pkgRetCallFoldSharesCalleeRet300
package p;
  function int f (int a); return a + 1; endfunction
  class K; int v; function int m(); return f(this.v); endfunction endclass
  function int c (int x); return f(x); endfunction
endpackage
module top; int r; p::K k; initial begin k = new; r = k.m() + p::c(1); end endmodule
