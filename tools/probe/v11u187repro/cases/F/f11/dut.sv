// § foreachAssocLoopVarIdxTs183 (a subroutine-local string-keyed array)
module top(output int o);
  function automatic int f();
    int m[string];
    int n;
    m["a"] = 1;
    foreach (m[k]) n = n + m[k];
    return n;
  endfunction
  assign o = f();
endmodule
