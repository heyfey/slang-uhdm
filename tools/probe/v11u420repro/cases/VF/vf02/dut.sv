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
  import p::*;
  logic [3:0] b;
endmodule
module mid;
  import p::*;
  child u();
endmodule
module top;
  import p::*;
  mid m();
  logic [7:0] x;
endmodule
