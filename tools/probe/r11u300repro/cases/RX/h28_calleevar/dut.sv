// § pkgRetCallFoldSharesCalleeRet300
package p;
  int gb;
  function int f (int a); return a + gb; endfunction
  function int c (int x); return f(x); endfunction
endpackage
module top; int r; initial r = p::c(1); endmodule
