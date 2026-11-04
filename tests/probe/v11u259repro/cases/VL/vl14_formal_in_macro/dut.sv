// § cloneLoopVarHomeDeclTs259 (the whole function, formal and foreach, written inside a macro body)
`define MKF(nm) function automatic int nm(int off, ref addr_t addr[]); \
    foreach (addr[i]) addr[i] = addr[i] + off; \
    return 0; \
  endfunction
package p;
  typedef bit unsigned [63:0] addr_t;
  `MKF(f)
endpackage
package q;
  import p::*;
endpackage
module top;
endmodule
