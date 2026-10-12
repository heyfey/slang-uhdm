// § pkgRetCallFoldSharesCalleeRet300
package p;
  function int f (int a); return a + 1; endfunction
endpackage
module top;
  function int c (int x); return p::f(x); endfunction
  int r; initial r = c(1);
endmodule
