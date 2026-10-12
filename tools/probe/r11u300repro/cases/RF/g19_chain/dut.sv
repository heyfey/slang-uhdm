// § pkgRetCallFoldSharesCalleeRet300
package p;
  function int h (int a); return a - 1; endfunction
  function int f (int a); return h(a); endfunction
  function int c (int x); return f(x); endfunction
endpackage
module top; int r; initial r = p::c(1); endmodule
