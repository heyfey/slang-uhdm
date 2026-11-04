// § aliasParamStoredRead480 (type_id used through the alias)
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
  endclass
  typedef A #(K::w) A_t;
  typedef A_t::type_id tid_t;
endpackage
package c;
  import a::*;
  import b::*;
  class E;
    tid_t t;
  endclass
endpackage
module top;
  import c::*;
endmodule
