// § pkgRetCallFoldSharesCalleeRet300
package p;
  function int f (int a); return a + 1; endfunction
  class C; static function int m (int x); return f(x); endfunction endclass
  function int c (int x); return f(x); endfunction
endpackage
module top; int r; initial r = p::C::m(1) + p::c(2); endmodule
