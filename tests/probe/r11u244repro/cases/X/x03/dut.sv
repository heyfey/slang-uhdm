// § hpSelIdxPathTrailByChain244
package p;
  class item; int k; endclass
  class s_t; int v[4]; endclass
  function automatic int g(int a, int b = 2); return a + b; endfunction
  class pred;
    function void write(item rw, s_t pi);
      int z;
      z = g(.a(pi.v[rw.k]));
      z = g(pi.v[rw.k], );
      pi.v[g(.b(rw.k), .a(1))] = 1;
    endfunction
  endclass
endpackage
module top;
  p::pred w;
endmodule
