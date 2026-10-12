// § pkgRetCallFoldSharesCalleeRet300
package p;
  function integer f (integer a); return a + 1; endfunction
  function integer c (integer x); return f(x); endfunction
endpackage
module top; integer r; initial r = p::c(1); endmodule
