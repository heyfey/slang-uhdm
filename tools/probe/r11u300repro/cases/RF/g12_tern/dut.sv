// § pkgRetCallFoldSharesCalleeRet300
package p;
  function int f (int a); return a + 1; endfunction
  function int c (int x, bit s); return s ? f(x) : 0; endfunction
endpackage
module top; int r; initial r = p::c(1, 1); endmodule
