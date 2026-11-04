// § cloneLoopVarHomeDeclTs259 (foreach over a dynamic-array formal of a scalar typedef, as uvm_mem::get_addresses)
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
module top;
endmodule
