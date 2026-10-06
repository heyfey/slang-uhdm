// § cloneLoopVarHomeDeclTs259 (a fixed-size array formal)
package p;
  typedef bit [15:0] w_t;
  function int f(input w_t a[4]);
    int s;
    foreach (a[i])
      s += a[i];
    return s;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
endmodule
