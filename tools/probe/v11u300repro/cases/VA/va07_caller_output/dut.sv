// § pkgRetCallFoldSharesCalleeRet300
package p;
  function int f (int a); return a + 1; endfunction
  function int c (output int x); return f(x); endfunction
endpackage
module top; int r, q; initial r = p::c(q); endmodule
