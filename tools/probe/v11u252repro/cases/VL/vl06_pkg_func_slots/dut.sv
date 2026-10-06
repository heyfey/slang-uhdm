// § cloneLoopVarLocalElemTs252
package p;
  function automatic int sum();
    bit [7:0] vals[$];
    int t;
    foreach (vals[i]) t += vals[i][3:0] + vals[i][7 -: 2];
    return t;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
