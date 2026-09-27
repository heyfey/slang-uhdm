// § cloneLoopVarHomeObject183 with § incDecMemberSelIsLvalue184
package u;
  function automatic int cnt(int q[$]);
    int n[4];
    foreach (q[i]) n[i]++;
    return n[0];
  endfunction
endpackage
package s;
  import u::*;
  int z;
endpackage
module top; endmodule
