// § clsTdUnionBuilt237
// a parameterized class
package p;
class c #(int W = 8);
  typedef union packed { logic [W-1:0] a; bit [W-1:0] b; } u_t;
  u_t m_u;
endclass
class d;
  c #(16) h;
endclass
endpackage
module top;
endmodule
