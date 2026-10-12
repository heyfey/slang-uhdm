// § pkgRetCallFoldSharesCalleeRet300
package q;
  function int f (int a); return a + 1; endfunction
endpackage
package p;
  function int c (int x); return q::f(x); endfunction
endpackage
module top; int r; initial r = p::c(1); endmodule
