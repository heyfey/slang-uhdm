// § clsTdUnionBuilt237
// a parameterized class union with a type-parameter member and two specializations
package p;
class a #(type T = logic [3:0]);
  typedef union packed { T x; logic [$bits(T)-1:0] y; } u_t;
  u_t v;
endclass
endpackage
module top;
  p::a #(logic [7:0]) h1 = new;
  p::a h2 = new;
endmodule
