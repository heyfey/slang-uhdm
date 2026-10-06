// § cloneLoopVarHomeDeclTs259 (a local array variable, not a formal)
package p;
  typedef bit [15:0] w_t;
  function automatic int f();
    int s;
    w_t arr[4];
    foreach (arr[i])
      s += arr[i];
    return s;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
endmodule
