// § cloneLoopVarHomeDeclTs259 (a dynamic-array formal of int (no typedef))
package p;
  function automatic int f(ref int a[]);
    foreach (a[i])
      a[i] = 0;
    return 0;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
endmodule
