// § pkgRetCallFoldSharesCalleeRet300
package p;
  function int f (int a); return $urandom(); endfunction
  function logic [63:0] c (int x); return {f(x), f(x)}; endfunction
endpackage
module top; logic [63:0] r; initial r = p::c(1); endmodule
