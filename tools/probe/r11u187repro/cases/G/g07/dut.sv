// § cloneLoopVarHomeObject183 (a generate-scope caller of the imported function)
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
module top(output int o);
  import u::*;
  if (1) begin : g
    int q[$];
    always_comb o = cnt(q);
  end
endmodule
