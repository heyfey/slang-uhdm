// § pkgRetCallFoldSharesCalleeRet300
package p;
  function int f (int a); begin return a + 1; end endfunction
  function int c (int x); return f(x); endfunction
endpackage
module top; int r; initial r = p::c(1); endmodule
