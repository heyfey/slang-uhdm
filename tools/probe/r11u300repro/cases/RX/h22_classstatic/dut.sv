// § pkgRetCallFoldSharesCalleeRet300
package p;
  class K; static function int f (int a); return a + 1; endfunction endclass
  function int c (int x); return K::f(x); endfunction
endpackage
module top; int r; initial r = p::c(1); endmodule
