// § aliasCopyParamUnnamed478 (named overrides)
package u;
  class R #(type T = int);
    typedef R #(T) this_type;
  endclass
endpackage
package a;
  import u::*;
  class A #(int W = 1, int V = 2);
    typedef A #(.W(W), .V(V)) this_t;
    typedef R #(this_t) type_id;
  endclass
  typedef A #(.V(7)) A_t;
  class E; A_t h; endclass
endpackage
module top; import a::*; E e; endmodule
