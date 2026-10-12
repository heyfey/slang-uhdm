// § pkgRetCallFoldSharesCalleeRet300
package p;
  function automatic int f (int a); return a + 1; endfunction
  function automatic int c (ref int x); return f(x); endfunction
endpackage
module top; int r, q; initial r = p::c(q); endmodule
