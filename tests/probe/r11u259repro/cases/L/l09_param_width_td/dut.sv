// § cloneLoopVarHomeDeclTs259 (a typedef whose width is a package parameter expression (UVM_REG_ADDR_WIDTH-1))
package p;
  parameter int AW = 64;
  typedef bit unsigned [AW-1:0] addr_t;
  class c;
    extern function int f(addr_t off, ref addr_t addr[]);
  endclass
  function int c::f(addr_t off, ref addr_t addr[]);
    foreach (addr[i])
      addr[i] = addr[i] + off;
    return 0;
  endfunction
endpackage
package q;
  import p::*;
endpackage
interface ifc;
  import p::*;
endinterface
module top;
  ifc u();
endmodule
