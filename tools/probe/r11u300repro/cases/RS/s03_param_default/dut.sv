// § pkgRetCallFoldSharesCalleeRet300
package p;
  function int f (int a); return a + 1; endfunction
  parameter int P = f(3);
  function int c (int x); return f(x) + P; endfunction
endpackage
module top; int r; initial r = p::c(1); endmodule
