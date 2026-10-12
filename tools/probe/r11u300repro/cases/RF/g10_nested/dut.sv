// § pkgRetCallFoldSharesCalleeRet300
package p;
  function int g (int a); return a * 2; endfunction
  function int f (int a); return a + 1; endfunction
  function int c (int x); return f(g(x)); endfunction
endpackage
module top; int r; initial r = p::c(1); endmodule
