// § pkgRetCallFoldSharesCalleeRet300
package p;
  function int f (int a); return a + 1; endfunction
  function int c (int x); int k = 3; return f(k); endfunction
endpackage
module top; int r; initial r = p::c(1); endmodule
