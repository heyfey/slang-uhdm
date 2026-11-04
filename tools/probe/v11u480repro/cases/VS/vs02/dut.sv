// § aliasParamStoredRead480 (specialization typedef inside a class)
package u;
  class R #(type T = int);
    typedef R #(T) this_type;
    int y;
  endclass
endpackage
package a;
  import u::*;
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
    typedef A #(K::w) A_t;
    A_t h;
  endclass
endpackage
module top;
  import b::*;
endmodule
