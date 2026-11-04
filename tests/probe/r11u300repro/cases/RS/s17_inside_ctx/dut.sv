// § pkgRetCallFoldSharesCalleeRet300
package p;
  function int f (int a); return a + 1; endfunction
  function bit c (int x); return x inside {f(x), 3}; endfunction
endpackage
module top; bit r; initial r = p::c(1); endmodule
