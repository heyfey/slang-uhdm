// § cloneLoopVarHomeDeclTs259 (a queue formal)
package p;
  typedef logic [7:0] byte_t;
  function automatic int f(ref byte_t b[$]);
    int s;
    foreach (b[i])
      s += b[i];
    return s;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
endmodule
