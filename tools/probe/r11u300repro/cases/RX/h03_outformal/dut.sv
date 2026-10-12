// § pkgRetCallFoldSharesCalleeRet300
package p;
  function int f (input int a, output int o); o = a; return a + 1; endfunction
  function int c (int x); int z; return f(x, z); endfunction
endpackage
module top; int r; initial r = p::c(1); endmodule
