// § cloneLoopVarHomeDeclTs259 (an associative formal int m[addr_t]: element and index differ)
package p;
  typedef bit unsigned [63:0] addr_t;
  function automatic int f(ref int m[addr_t]);
    int n = 0;
    foreach (m[k])
      n++;
    return n;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
endmodule
