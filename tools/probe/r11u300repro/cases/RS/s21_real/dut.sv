// § pkgRetCallFoldSharesCalleeRet300
package p;
  function real f (real a); return a + 1; endfunction
  function real c (real x); return f(x); endfunction
endpackage
module top; real r; initial r = p::c(1.0); endmodule
