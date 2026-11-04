// § hpSelIdxPathTrailByChain244
package p;
  class inner; int k; endclass
  class item; inner n; int addr; endclass
  class s_t; bit addr[int]; int v[8]; endclass
  class pred;
    function int g(int a); return a; endfunction
    function void write(item rw, s_t pi);
      pi.addr[rw.n.k] = 1;
      pi.v[g(rw.addr)] = 2;
      pi.v[rw.addr + rw.n.k] = 3;
      pi.addr[{rw.addr}] = 0;
      if (pi.addr.exists(rw.addr)) pi.v[rw.addr] = pi.v[rw.n.k];
    endfunction
  endclass
endpackage
module top; import p::*; pred w; initial w = new(); endmodule
