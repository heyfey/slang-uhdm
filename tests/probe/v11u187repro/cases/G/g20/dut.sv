// § cloneLoopVarHomeObject183 (two-dimensional formal, one loop variable)
package u;
  function automatic int tot(int a[2][3]);
    int n;
    foreach (a[i]) n = n + a[i][0];
    return n;
  endfunction
endpackage
package s;
  import u::*;
  int z;
endpackage
module top; endmodule
