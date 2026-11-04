// § pkgRetCallFoldSharesCalleeRet300
package p;
  function int unsigned f (int unsigned a); return a + 1; endfunction
  function int unsigned c (int unsigned x); return f(x); endfunction
endpackage
module top; int unsigned r; initial r = p::c(1); endmodule
