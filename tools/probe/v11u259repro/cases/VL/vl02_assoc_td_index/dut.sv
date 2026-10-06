// § cloneLoopVarHomeDeclTs259 (an associative formal indexed by the typedef, element the same typedef)
package p;
  typedef bit unsigned [63:0] addr_t;
  function automatic int f(ref addr_t m[addr_t]);
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
