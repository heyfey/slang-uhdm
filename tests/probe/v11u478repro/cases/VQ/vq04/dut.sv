// § aliasCopyParamUnnamed478 (a type and a value parameter)
package u;
  class R #(type T = int);
    typedef R #(T) this_type;
  endclass
endpackage
package a;
  import u::*;
  class A #(type X = int, int W = 1);
    typedef A #(X, W) this_t;
    typedef R #(this_t) type_id;
    X d;
  endclass
  class K; localparam w = 3; endclass
  typedef A #(byte, K::w) A_t;
endpackage
package c;
  import a::*;
  class E; A_t h; endclass
endpackage
module top; import c::*; E e; endmodule
