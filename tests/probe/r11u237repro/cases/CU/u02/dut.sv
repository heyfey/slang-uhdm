// § clsTdUnionBuilt237
// a packed union of vectors beside a struct
package p;
class c;
  typedef union packed { logic [31:0] w; logic [3:0][7:0] b; } u_t;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } s_t;
  u_t m_u;
  s_t m_s;
endclass
endpackage
module top;
endmodule
