// § pkgRetCallFoldSharesCalleeRet300
package p;
  parameter int K = 4;
  function int f (int a); return a + K; endfunction
  function int c (int x); return f(x); endfunction
endpackage
module top; int r; initial r = p::c(1); endmodule
