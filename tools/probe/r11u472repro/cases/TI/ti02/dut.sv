// § clsLocalTdTopHomeInst446 (r11u472 decode grid: the vpiInstance of a specialization's class-local this_t; no pass 472 law)
package a;
  class A #(int W = 1);
    typedef A #(W) this_t;
    int x;
  endclass
endpackage
package b;
  import a::*;
  class K;
    localparam w = 2;
  endclass
  typedef A #(K::w) A_t;
endpackage
module top;
  import b::*;
  A_t h;
endmodule
