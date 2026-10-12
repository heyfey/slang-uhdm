// § pkgRetCallFoldSharesCalleeRet300
package p;
  function int f (int a); return a + 1; endfunction
  function void v (int x); int y; y = f(x); endfunction
endpackage
module top; initial p::v(1); endmodule
