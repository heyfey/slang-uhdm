// § cloneLoopVarHomeDeclTs259 (the same inside a class method with an out-of-body definition)
package p;
  typedef bit unsigned [63:0] addr_t;
  class c;
    extern function int f(int off, ref addr_t addr[]);
  endclass
  function int c::f(int off, ref addr_t addr[]);
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
