// § clsLocalTdTopHomeInst446 (r11u472 decode grid: the vpiInstance of a specialization's class-local this_t; no pass 472 law)
package a;
  class R #(type T = int);
    int y;
  endclass
  class A #(int W = 1, int V = 2);
    typedef A #(W, V) this_t;
    typedef R #(this_t) type_id;
    int x;
  endclass
endpackage
package b;
  import a::*;
  class K;
    localparam w = 16;
    localparam v = 32;
  endclass
  typedef A #(K::w, K::v) A_t;
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
