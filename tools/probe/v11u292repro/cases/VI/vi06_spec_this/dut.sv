// § clsScopedChainIdxDirect292
package p;
  class b #(int W = 2); int hval; static b #(W) stat = new(); endclass
  class r;
    int a[8]; int hv; r self;
    function void f();
      int x;
      x = a[b#(4)::stat.hval];
      x = a[b#()::stat.hval];
      x = a[this.hv];
      x = a[self.hv];
      x = a[int'(b#(4)::stat.hval)];
      x = a[b#(4)::stat.hval[0]];
    endfunction
  endclass
endpackage
module top; endmodule
