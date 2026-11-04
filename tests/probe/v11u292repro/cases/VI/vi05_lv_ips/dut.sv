// § clsScopedChainIdxDirect292
package p;
  class b; int hval; static b stat = new(); endclass
  class r;
    logic [31:0] v; int a[8];
    task t();
      v[b::stat.hval +: 4] = '0;
      v[b::stat.hval -: 4] = v[b::stat.hval +: 4];
      a[a[b::stat.hval]] = 1;
      a[b::stat.hval]++;
    endtask
  endclass
endpackage
module top; endmodule
