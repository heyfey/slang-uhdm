// § pkgRetCallFoldSharesCalleeRet300
package p;
  function int f (int a, int b); return a + b; endfunction
  function int c (int x); return f(x, x); endfunction
endpackage
module top; int r; initial r = p::c(1); endmodule
