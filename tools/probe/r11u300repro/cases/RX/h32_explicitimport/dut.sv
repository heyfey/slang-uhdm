// § pkgRetCallFoldSharesCalleeRet300
package q;
  function automatic int f (int a); return a + 1; endfunction
endpackage
package p;
  import q::f;
  function automatic int c (int x); return f(x); endfunction
endpackage
module top; int r; initial r = p::c(1); endmodule
