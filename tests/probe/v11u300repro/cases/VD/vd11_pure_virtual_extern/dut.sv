// § pkgRetCallFoldSharesCalleeRet300
package p;
  function int f (int a); return a + 1; endfunction
  virtual class B; pure virtual function int m (int x); endclass
  class D extends B; extern function int m (int x); endclass
  function int D::m (int x); return f(x); endfunction
  function int c (int x); return f(x); endfunction
endpackage
module top; int r; initial r = p::c(1); endmodule
