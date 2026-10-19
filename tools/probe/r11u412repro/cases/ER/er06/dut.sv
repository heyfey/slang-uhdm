// § enumRangedMemberSurelogVal412
class C;
  enum {A=2, B} p;
  typedef enum {G[2]=7, H} g_e;
endclass
package pk;
  typedef struct packed { enum logic [1:0] {Q=1, R} f; } s_t;
endpackage
module top();
  C c;
  pk::s_t s;
endmodule
