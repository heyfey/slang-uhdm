// § pkgRetCallFoldSharesCalleeRet300
package p;
  function int f (int a); return a + 1; endfunction
  function int c (int x); if (x > 0) return f(x); return 0; endfunction
endpackage
module top; int r; initial r = p::c(1); endmodule
