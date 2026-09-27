package u;
  function automatic int cnt(int q[$]);
    int n;
    foreach (q[i]) n = n + 1;
    return n;
  endfunction
endpackage
package s;
  import u::*;
  int z;
endpackage
module top; endmodule
