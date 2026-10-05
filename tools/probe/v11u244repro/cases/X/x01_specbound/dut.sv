// § hpSelIdxPathTrailByChain244
package p;
  class item; int addr; endclass
  class cfg #(int W = 4); int v[W]; static int k = W - 1; endclass
  class pred #(int N = 2);
    cfg #(N*2) c; cfg #(.W(3)) d;
    function void write(item rw);
      c.v[rw.addr] = N;
      d.v[c.v[rw.addr]] = 1;
      c.v[cfg#(N)::k] = 2;
    endfunction
  endclass
endpackage
module top; import p::*; pred #(3) w; initial w = new(); endmodule
