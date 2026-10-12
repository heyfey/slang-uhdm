// § pkgRetCallFoldSharesCalleeRet300
package p;
  function automatic int c (int x); return c(x) + 1; endfunction
  function automatic int d (int x); return d(x); endfunction
endpackage
module top; endmodule
