// § cloneLoopVarHomeDeclTs259 (two formals of the same typedef, the array second (uvm_mem::get_addresses' shape))
package p;
  typedef bit unsigned [63:0] addr_t;
  class c;
    extern function int f(addr_t off = 0, ref addr_t addr[]);
  endclass
  function int c::f(addr_t off = 0, ref addr_t addr[]);
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
