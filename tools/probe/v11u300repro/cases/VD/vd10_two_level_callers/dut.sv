// § pkgRetCallFoldSharesCalleeRet300
package p;
  function int f (int a); return a + 1; endfunction
  function int c (int x); return f(x); endfunction
  function int d (int y); return c(y); endfunction
endpackage
module top; int r; initial r = p::d(1); endmodule
