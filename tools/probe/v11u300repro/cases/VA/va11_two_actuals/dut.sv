// § pkgRetCallFoldSharesCalleeRet300
package p;
  function int f (int a, int b); return a + b; endfunction
  function int c (int x, int y); return f(x, y); endfunction
endpackage
module top; int r; initial r = p::c(1, 2); endmodule
