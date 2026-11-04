// § pkgRetCallFoldSharesCalleeRet300
package p;
  function automatic int f (int a); return a + 1; endfunction
  function automatic int c (int y); int t = 3; return f(t); endfunction
endpackage
module top; int r; initial r = p::c(1); endmodule
