// § pkgLateTsLoopVarCapture420
package p;
  function automatic int f();
    int b[4];
    int s = 0;
    foreach (b[j]) s += b[j];
    return s;
  endfunction
endpackage
module child;
  logic [1:0] j;
endmodule
module top;
  import p::*;
  child u();
endmodule
