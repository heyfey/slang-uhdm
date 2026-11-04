// § cloneLoopVarHomeDeclTs259 (two importer packages)
package p;
  typedef bit unsigned [63:0] addr_t;
  function automatic int f(int off, ref addr_t addr[]);
    foreach (addr[i])
      addr[i] = addr[i] + off;
    return 0;
  endfunction
endpackage
package q;
  import p::*;
endpackage
package r;
  import p::*;
endpackage
module top;
endmodule
