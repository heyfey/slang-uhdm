// § pkgRetCallFoldSharesCalleeRet300
package p;
  function shortint f (shortint a); return a + 1; endfunction
  function shortint c (shortint x); return f(x); endfunction
endpackage
module top; shortint r; initial r = p::c(1); endmodule
