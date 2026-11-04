// § cloneLoopVarHomeObject183
package u;
  function automatic int lsb(int q[$]);
    int n;
    foreach (q[i]) n = n + q[i][1:0];
    return n;
  endfunction
endpackage
package s;
  import u::*;
  int z;
endpackage
module top; endmodule
