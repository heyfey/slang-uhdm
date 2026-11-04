// § cloneLoopVarHomeObject183 (two-dimensional fixed formal, two loop variables)
package u;
  function automatic int tot(int a[2][3]);
    int n;
    foreach (a[i, j]) n = n + a[i][j];
    return n;
  endfunction
endpackage
package s;
  import u::*;
  int z;
endpackage
module top; endmodule
