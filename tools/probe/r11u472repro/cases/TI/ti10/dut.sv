// § clsLocalTdTopHomeInst446 (r11u472 decode grid: the vpiInstance of a specialization's class-local this_t; no pass 472 law)
interface ifc #(int W = 1);
  logic [W-1:0] d;
endinterface
package a;
  class A #(int W = 1);
    typedef A #(W) this_t;
    int x;
  endclass
endpackage
package b;
  import a::*;
  typedef A #(4) A_t;
  typedef virtual ifc #(4) vif_t;
endpackage
module top;
  import b::*;
  A_t h;
  ifc #(4) u();
endmodule
