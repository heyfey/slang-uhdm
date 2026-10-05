// § hpSelIdxPathTrailByChain244
package p;
  class item; int k; int m; endclass
  class el; int m; int v[4]; endclass
  class pred;
    el q[4];
    function void write(item rw, el e);
      q[rw.k].m = 1;
      q[rw.k].v[rw.m] = 2;
      e.v[q[rw.k].m] = 3;
    endfunction
  endclass
endpackage
module top; import p::*; pred w; initial w = new(); endmodule
