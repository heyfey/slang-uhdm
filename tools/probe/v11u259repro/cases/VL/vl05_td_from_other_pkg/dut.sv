// § cloneLoopVarHomeDeclTs259 (the typedef from a third package r that p imports)
package r;
  typedef bit unsigned [63:0] addr_t;
endpackage
package p;
  import r::*;
  function automatic int f(int off, ref addr_t addr[]);
    foreach (addr[i])
      addr[i] = addr[i] + off;
    return 0;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
endmodule
