// § pkgRetCallFoldSharesCalleeRet300
package p;
  function automatic int f (int a, int b = 2); return a + b; endfunction
  function automatic int c (int x); return f(x, ); endfunction
endpackage
module top; int r; initial r = p::c(1); endmodule
