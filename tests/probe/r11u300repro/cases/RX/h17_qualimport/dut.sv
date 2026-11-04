// § pkgRetCallFoldSharesCalleeRet300
package q;
  function int f (int a); return a + 1; endfunction
endpackage
package p;
  import q::*;
  function int c (int x); return q::f(x); endfunction
  function int d (int x); return f(x); endfunction
endpackage
module top; int r; initial r = p::c(1) + p::d(2); endmodule
