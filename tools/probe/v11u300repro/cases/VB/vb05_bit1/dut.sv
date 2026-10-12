// § pkgRetCallFoldSharesCalleeRet300
package p;
  function bit f (bit a); return a + 1; endfunction
  function bit c (bit x); return f(x); endfunction
endpackage
module top; bit r; initial r = p::c(1); endmodule
