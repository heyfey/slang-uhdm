// § hpSelIdxPathTrailByChain244
package p;
  class base; int k; int arr[4]; endclass
  class item; int addr; endclass
  class der extends base;
    int v[4]; der o;
    function void f(item rw);
      o.v[this.k] = 1;
      o.v[super.k] = 2;
      this.v[rw.addr] = 3;
      o.arr[o.k] = 4;
      o.v[this.o.k] = 5;
    endfunction
  endclass
endpackage
module top; import p::*; der w; initial w = new(); endmodule
