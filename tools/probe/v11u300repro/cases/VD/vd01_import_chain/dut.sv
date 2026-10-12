// § pkgRetCallFoldSharesCalleeRet300
package r;
  function int f (int a); return a + 1; endfunction
endpackage
package q;
  import r::*;
  function int g (int b); return f(b); endfunction
endpackage
package p;
  import q::*;
  function int c (int x); return g(x); endfunction
endpackage
module top; int r0; initial r0 = p::c(1); endmodule
