// § cloneLoopVarHomeDeclTs259 (the formal written p::addr_t, package-qualified)
package p;
  typedef bit unsigned [63:0] addr_t;
  function automatic int f(int off, ref p::addr_t addr[]);
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
