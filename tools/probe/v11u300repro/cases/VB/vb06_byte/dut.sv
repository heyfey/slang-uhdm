// § pkgRetCallFoldSharesCalleeRet300
package p;
  function byte f (byte a); return a + 1; endfunction
  function byte c (byte x); return f(x); endfunction
endpackage
module top; byte r; initial r = p::c(1); endmodule
