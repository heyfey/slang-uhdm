// § clsLocalTdTopHomeInst446 (r11u472 decode grid: the vpiInstance of a specialization's class-local this_t; no pass 472 law)
package a;
  class A #(int W = 1);
    typedef A #(W) this_t;
    int x;
  endclass
endpackage
package b;
  import a::*;
  typedef A #(4) A_t;
endpackage
package c;
  import a::*;
  import b::*;
  class E;
    A_t h;
  endclass
endpackage
module top;
  import c::*;
endmodule
