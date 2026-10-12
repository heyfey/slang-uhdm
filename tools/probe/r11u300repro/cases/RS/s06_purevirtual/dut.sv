// § pkgRetCallFoldSharesCalleeRet300
package p;
  function int f (int a); return a + 1; endfunction
  virtual class B; pure virtual function int m (int x); endclass
  class D extends B; virtual function int m (int x); return f(x); endfunction endclass
  function int c (int x); return f(x); endfunction
endpackage
module top; int r; p::D d; initial begin d = new; r = d.m(1) + p::c(1); end endmodule
