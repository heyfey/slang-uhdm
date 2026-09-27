// § cloneLoopVarHomeObject183
package u;
  function automatic int sum(int m[string]);
    int n;
    foreach (m[k]) n = n + m[k];
    return n;
  endfunction
endpackage
package s;
  import u::*;
  int z;
endpackage
module top; endmodule
