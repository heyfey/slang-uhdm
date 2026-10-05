// § clsTdUnionClsEnumMemberShares237
// a class union whose member is another class's enum typedef, and a third class reads it
package p;
class e;
  typedef enum logic [1:0] { A, B, C } k_t;
endclass
class a;
  typedef union packed { e::k_t k; logic [1:0] r; } u_t;
  u_t v;
endclass
class b;
  a::u_t w;
endclass
endpackage
module top;
  p::b h = new;
endmodule
