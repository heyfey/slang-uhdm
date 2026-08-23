// r10v110 arm v8 — the UNBOUND half: a dotted `new [n]` whose TARGET is not a
// dynamic array, so slang refuses to bind the RHS.  Surelog's rule is a GRAMMAR
// alternative, so golden must take the SAME collapsed shape either way.
package Uu8;
  class K8;
    int  dyn8[];
    int  fix8[4];
    K8   h8;
    int  s8;
  endclass
endpackage
module v8top;
  import Uu8::*;
  K8 k8;
  initial begin
    k8 = new();
    k8.fix8 = new [3];     // v8j01 dotted new[] onto a FIXED array (unbindable)
    k8.dyn8 = new [3];     // v8j02 dotted new[] onto a DYN array   (in law)
    k8.s8   = 3;           // v8j03 control
  end
endmodule
