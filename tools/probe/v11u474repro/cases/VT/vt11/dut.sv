// § thisTdRegDefView474 (attack: one type parameter)
package u; class R #(type T = int); int y; endclass endpackage
package a;
  import u::*;
  class A #(type T = int);
    typedef A #(T) this_t;
    typedef R #(this_t) type_id;
    T x;
  endclass
endpackage
package b; import a::*; typedef A #(byte) A_t; endpackage
package c; import a::*; import b::*; class E; A_t h; endclass endpackage
module top; import c::*; endmodule
