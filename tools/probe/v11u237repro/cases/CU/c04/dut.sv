// § clsTdUnionBuilt237
// class b's union nests class a's union
package p;
class a;
  typedef union packed { logic [7:0] x; bit [7:0] y; } u_t;
endclass
class b;
  typedef union packed { a::u_t w; logic [7:0] z; } w_t;
  w_t v;
endclass
endpackage
module top;
  p::b h = new;
endmodule
