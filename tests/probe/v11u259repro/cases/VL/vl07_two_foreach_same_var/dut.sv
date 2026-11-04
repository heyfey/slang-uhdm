// § cloneLoopVarHomeDeclTs259 (two foreach loops over the same formal, both named i)
package p;
  typedef bit unsigned [63:0] addr_t;
  function automatic int f(int off, ref addr_t addr[]);
    foreach (addr[i])
      addr[i] = addr[i] + off;
    foreach (addr[i])
      addr[i] = addr[i] - 1;
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
