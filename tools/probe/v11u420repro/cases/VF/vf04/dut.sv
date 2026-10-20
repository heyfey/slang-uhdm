// § pkgLateTsNetCapture420
package p;
  class C;
    int b[2][3];
    extern function int f();
  endclass
  function int C::f();
    int s = 0;
    foreach (b[i, j]) s += b[i][j];
    return s;
  endfunction
endpackage
import p::*;
module top;
  logic [5:0] b;
endmodule
