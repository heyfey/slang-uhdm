// § pkgRetCallFoldSharesCalleeRet300
package p;
  parameter int K = 7;
  function int f (int a); return a + 1; endfunction
  function int c (int x); return f(K); endfunction
endpackage
module top; int r; initial r = p::c(1); endmodule
