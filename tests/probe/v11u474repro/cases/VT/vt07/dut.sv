// § thisTdRegDefView474 (attack: the nested typedef named self_t)
package u; class R #(type T = int); int y; endclass endpackage
package a;
  import u::*;
  class A #(int W = 1, int V = 2);
    typedef A #(W, V) self_t;
    typedef R #(self_t) type_id;
    int x;
  endclass
endpackage
package b; import a::*; class K; localparam w = 16; localparam v = 32; endclass typedef A #(K::w, K::v) A_t; endpackage
package c; import a::*; import b::*; class E; A_t h; endclass endpackage
module top; import c::*; endmodule
