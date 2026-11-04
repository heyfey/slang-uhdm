// § aliasCopyParamUnnamed478 (a class-scoped and a literal argument)
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
  class B #(int W = 1, int V = 2);
    typedef B #(W, V) this_t;
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
  typedef A #(K::w, 7) A_t;

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
