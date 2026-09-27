// § cloneLoopVarHomeObject183 (associative array with a byte index)
package u;
  function automatic int sum(int m[byte]);
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
