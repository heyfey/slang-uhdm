// § aliasParamStoredRead480 (default arguments only, used in a module variable)
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
  typedef A #() A_t;
endpackage
module top;
  import a::*;
  import b::*;
  A_t h;
endmodule
