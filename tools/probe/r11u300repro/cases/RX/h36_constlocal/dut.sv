// § pkgRetCallFoldSharesCalleeRet300
package p;
  function int f (int a); return a + 1; endfunction
  function automatic int c (int x); const int k = 3; return f(k); endfunction
endpackage
module top; int r; initial r = p::c(1); endmodule
