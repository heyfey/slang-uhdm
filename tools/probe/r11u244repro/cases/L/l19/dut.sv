// § hpSelIdxPathTrailByChain244
package p;
  class s_t;
    bit addr[int];
    int v[4];
    s_t nx;
  endclass
  class item;
    int addr;
    int k;
  endclass
  class pred;
    s_t m;
    function void write(item rw, s_t pi);
      int z;
      pi.v[this.m.v[rw.k]] = 1;
      z = pi.v[this.m.v[0]];
    endfunction
  endclass
endpackage
module top;
  import p::*;
  pred w;
  initial w = new();
endmodule
