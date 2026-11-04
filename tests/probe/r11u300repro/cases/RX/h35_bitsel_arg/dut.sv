// § pkgRetCallFoldSharesCalleeRet300
package p;
  function int f (int a); return a + 1; endfunction
  function int c (logic [7:0] x); return f(x[0]); endfunction
endpackage
module top; int r; initial r = p::c(8'h1); endmodule
