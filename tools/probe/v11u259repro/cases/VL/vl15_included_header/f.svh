// § cloneLoopVarHomeDeclTs259 (header body)
  function automatic int f(int off, ref addr_t addr[]);
    foreach (addr[i])
      addr[i] = addr[i] + off;
    return 0;
  endfunction
