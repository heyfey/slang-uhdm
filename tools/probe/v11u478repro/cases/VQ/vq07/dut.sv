// § aliasCopyParamUnnamed478 (an imported package parameter as the argument)
package q;
  parameter int QW = 12;
endpackage
package u;
  class R #(type T = int);
    typedef R #(T) this_type;
  endclass
endpackage
package a;
  import u::*;
  class A #(int W = 1, int V = 2);
    typedef A #(W, V) this_t;
    typedef R #(this_t) type_id;
  endclass
endpackage
package b;
  import q::*; import a::*;
  typedef A #(QW, 3) A_t;
  class E; A_t h; endclass
endpackage
module top; import b::*; E e; endmodule
