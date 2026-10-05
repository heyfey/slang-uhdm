// § hpSelIdxPathTrailByChain244
package p;
  class item; int k; int m; logic [15:0] d; endclass
  class s_t; int v[8]; logic [31:0] d; s_t o; int q[$]; endclass
  class pred;
    function void write(item rw, s_t pi);
      pi.v[rw.k]++;
      --pi.v[rw.m];
      pi.v[-rw.k] = 1;
      pi.v[~rw.m] = 2;
      pi.v[pi.o.v[rw.k]] = 3;
      pi.v[later(rw.k)] = 4;
      pi.d[rw.k +: 2] = 2'b1;
      pi.d[rw.k*2 -: 2] = 2'b1;
      {>>{pi.v[rw.k]}} = {rw.d, rw.d};
      pi.q[rw.k] = pi.q[$];
    endfunction
    function int later(int a); return a; endfunction
  endclass
endpackage
module top; import p::*; pred w; initial w = new(); endmodule
