// § cloneLoopVarHomeObject183 (associative array with an int index)
package u;
  function automatic int sum(int m[int]);
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
