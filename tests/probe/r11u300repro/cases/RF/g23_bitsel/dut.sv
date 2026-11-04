// § pkgRetCallFoldSharesCalleeRet300
package p;
  function bit f (logic [7:0] a); return a[0]; endfunction
  function bit c (logic [7:0] x); return f(x); endfunction
endpackage
module top; bit r; initial r = p::c(8'h1); endmodule
