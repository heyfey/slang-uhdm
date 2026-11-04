// § hpSelIdxPathTrailByChain244
package p;
  class item; int addr; int k; endclass
  class s_t; int v[8]; endclass
  class pred;
    function int g(int a, int b = 1); return a + b; endfunction
    function void write(item rw, s_t pi);
      pi.v[g(.a(rw.addr))] = 1;
      pi.v[g(rw.k, )] = 2;
    endfunction
  endclass
endpackage
module top; import p::*; pred w; initial w = new(); endmodule
