// § aliasParamStoredRead480 (package-localparam arguments)
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
  localparam w = 16;
  typedef A #(w, 3) A_t;
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
