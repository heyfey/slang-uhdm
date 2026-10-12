// § pkgRetCallFoldSharesCalleeRet300
package p;
  function int f (int a); return a + 1; endfunction
  class K;
    extern function int m (int x);
  endclass
  function int K::m (int x); return f(x); endfunction
endpackage
module top; int r; p::K k; initial begin k = new; r = k.m(1); end endmodule
