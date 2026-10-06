// § cloneLoopVarHomeDeclTs259 (a two-dimensional dynamic formal, foreach (addr[i, j]))
package p;
  typedef bit unsigned [63:0] addr_t;
  function automatic int f(int off, ref addr_t addr[][]);
    foreach (addr[i, j])
      addr[i][j] = addr[i][j] + off;
    return 0;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
endmodule
