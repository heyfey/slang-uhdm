// § cloneLoopVarHomeDeclTs259 (two files, the importer in the second with the formal at the same position)
package q;
  typedef bit unsigned [63:0] addr_t;
  import p::f;
  function automatic int g(int off, ref addr_t addr[]);
    foreach (addr[i])
      addr[i] = addr[i] + off;
    return 0;
  endfunction
endpackage
module top;
endmodule
