// § pkgRetCallFoldSharesCalleeRet300
package p;
  class K; extern static function int m (int x); endclass
  function int f (int a); return a + 1; endfunction
  function int K::m (int x); return f(x); endfunction
  function int c (int x); return K::m(x); endfunction
endpackage
module top; int r; initial r = p::c(1); endmodule
