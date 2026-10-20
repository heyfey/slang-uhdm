// § pkgLateTsLoopVarCapture420
package p;
  class C;
    int b[$];
    extern function int f();
  endclass
  function int C::f();
    int s = 0;
    foreach (b[k]) s += b[k];
    return s;
  endfunction
endpackage
import p::*;
module top(input logic [2:0] k);
endmodule
