// § pkgLateTsLoopVarCapture420
package p;
  function automatic int f();
    int b[4];
    int s = 0;
    foreach (b[j]) s += b[j];
    return s;
  endfunction
endpackage
import p::*;
module top;
  logic [1:0] j;
endmodule
