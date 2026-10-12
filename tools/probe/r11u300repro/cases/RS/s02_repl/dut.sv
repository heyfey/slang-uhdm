// § pkgRetCallFoldSharesCalleeRet300
package p;
  function int f (int a); return a + 1; endfunction
  function logic [63:0] c (int x); return {2{f(x)}}; endfunction
endpackage
module top; logic [63:0] r; initial r = p::c(1); endmodule
