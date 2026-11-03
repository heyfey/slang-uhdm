// § thisTdRegDefView474 (attack: specialization extended by a class)
package u; class R #(type T = int); int y; endclass endpackage
package a;
  import u::*;
  class A #(int W = 1, int V = 2);
    typedef A #(W, V) this_t;
    typedef R #(this_t) type_id;
    int x;
  endclass
endpackage
package b; import a::*; class K; localparam w = 16; localparam v = 32; endclass typedef A #(K::w, K::v) A_t; class D extends A_t; endclass endpackage
module top; import b::*; D d; endmodule
