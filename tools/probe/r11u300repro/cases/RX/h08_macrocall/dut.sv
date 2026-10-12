// § pkgRetCallFoldSharesCalleeRet300
`define CALLF(v) f(v)
package p;
  function int f (int a); return a + 1; endfunction
  function int c (int x); return `CALLF(x); endfunction
endpackage
module top; int r; initial r = p::c(1); endmodule
