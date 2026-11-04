// § cloneLoopVarHomeObject183 (queue of strings formal, called from a module)
package u;
  function automatic int cnt(string q[$]);
    int n;
    foreach (q[i]) n = n + q[i].len();
    return n;
  endfunction
endpackage
package s;
  import u::*;
  function automatic int g(string q[$]); return cnt(q); endfunction
endpackage
module top(output int o);
  import s::*;
  string q[$];
  initial o = g(q);
endmodule
