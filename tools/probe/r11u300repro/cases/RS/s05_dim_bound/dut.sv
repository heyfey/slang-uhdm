// § pkgRetCallFoldSharesCalleeRet300
package p;
  function int f (int a); return a + 1; endfunction
  localparam int W = f(3);
  function logic [W-1:0] c (logic [W-1:0] x); return f(x); endfunction
endpackage
module top; logic [3:0] r; initial r = p::c(4'h1); endmodule
