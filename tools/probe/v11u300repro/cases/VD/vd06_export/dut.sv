// § pkgRetCallFoldSharesCalleeRet300
package q;
  function int f (int a); return a + 1; endfunction
endpackage
package p;
  import q::*;
  export q::*;
  function int c (int x); return f(x); endfunction
endpackage
package z;
  import p::*;
  function int e (int x); return f(x); endfunction
endpackage
module top; int r; initial r = p::c(1) + z::e(2); endmodule
