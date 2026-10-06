// § cloneLoopVarHomeDeclTs259 (a function-level local array and a formal of the same typedef, a foreach over each)
package p;
  typedef bit unsigned [63:0] addr_t;
  function automatic int f(int off, ref addr_t addr[]);
    addr_t tmp[];
    foreach (addr[i])
      addr[i] = off;
    foreach (tmp[k])
      tmp[k] = off;
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
