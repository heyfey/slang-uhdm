// § pkgRetCallFoldSharesCalleeRet300
package p;
  class C #(int W = 2); static function int g(); return W; endfunction endclass
  function int f (int a); return a + 1; endfunction
  function int c (int x); return f(x) + C#(4)::g(); endfunction
endpackage
module top; int r; initial r = p::c(1); endmodule
