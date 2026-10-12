// § pkgRetCallFoldSharesCalleeRet300
package p;
  int gv;
  function int f (int a); return a + 1; endfunction
  function int c (int x); return f(gv); endfunction
endpackage
module top; int r; initial r = p::c(1); endmodule
