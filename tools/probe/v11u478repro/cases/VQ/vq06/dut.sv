// § aliasCopyParamUnnamed478 ($unit classes)
class R #(type T = int);
  typedef R #(T) this_type;
endclass
class A #(int W = 1, int V = 2);
  typedef A #(W, V) this_t;
  typedef R #(this_t) type_id;
endclass
class K; localparam w = 11; endclass
typedef A #(K::w, 4) A_t;
class E; A_t h; endclass
module top; E e; endmodule
