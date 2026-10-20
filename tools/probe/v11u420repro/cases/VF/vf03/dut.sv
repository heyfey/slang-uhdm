// § pkgLateTsNetCapture420
package p;
  class C;
    int b[$];
    extern function int f();
  endclass
  function int C::f();
    int s = 0;
    foreach (b[i]) s += b[i];
    return s;
  endfunction
endpackage
module child;
  logic [3:0] b;
endmodule
module top;
  import p::*;
  child u();
endmodule
