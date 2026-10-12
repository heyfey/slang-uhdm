// § pkgRetCallFoldSharesCalleeRet300
package p;
  function longint f (longint a); return a + 4294967296; endfunction
  function longint c (longint x); return f(x); endfunction
endpackage
module top; longint r; initial r = p::c(1); endmodule
