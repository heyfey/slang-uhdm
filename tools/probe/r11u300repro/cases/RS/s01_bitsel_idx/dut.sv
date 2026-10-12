// § pkgRetCallFoldSharesCalleeRet300
package p;
  function int f (int a); return a + 1; endfunction
  function bit c (logic [7:0] x, int i); return x[f(i)]; endfunction
endpackage
module top; bit r; initial r = p::c(8'h3, 1); endmodule
