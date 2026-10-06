// § cloneLoopVarHomeDeclTs259 (file a: the home package)
package p;
  typedef bit unsigned [63:0] addr_t;
  function automatic int f(int off, ref addr_t addr[]);
    foreach (addr[i])
      addr[i] = addr[i] + off;
    return 0;
  endfunction
endpackage
