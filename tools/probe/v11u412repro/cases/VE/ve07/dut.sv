// § enumRangedMemberSurelogVal412
class C;
  enum {a, b=3, c} f;
  typedef enum {u[2], w} t_t;
  t_t g;
endclass
module top;
  C c0;
endmodule
