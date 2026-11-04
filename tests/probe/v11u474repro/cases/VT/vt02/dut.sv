// § thisTdRegDefView474 (attack: specialization as a class property, no package typedef)
package u; class R #(type T = int); int y; endclass endpackage
package a;
  import u::*;
  class A #(int W = 1, int V = 2);
    typedef A #(W, V) this_t;
    typedef R #(this_t) type_id;
    int x;
  endclass
endpackage
package b; import a::*; class K; localparam w = 16; localparam v = 32; endclass endpackage
package c; import a::*; import b::*; class E; A #(K::w, K::v) h; endclass endpackage
module top; import c::*; endmodule
