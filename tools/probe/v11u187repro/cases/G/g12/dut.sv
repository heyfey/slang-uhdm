// § cloneLoopVarHomeObject183 (packed vector formal)
package u;
  function automatic int ones(logic [7:0] v);
    int n;
    foreach (v[i]) n = n + v[i];
    return n;
  endfunction
endpackage
package s;
  import u::*;
  function automatic int g(logic [7:0] v); return ones(v); endfunction
endpackage
module top; endmodule
