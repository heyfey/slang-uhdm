// § pkgRetCallFoldSharesCalleeRet300
package p;
  function int f (int a); return a + 1; endfunction
  function logic [1:0] c (logic [7:0] x, int i); return x[f(i) +: 2]; endfunction
endpackage
module top; logic [1:0] r; initial r = p::c(8'h3, 1); endmodule
