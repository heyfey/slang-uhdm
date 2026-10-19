// § enumRangedMemberSurelogVal412
typedef enum logic [2:0] {A, B=3, C[2], D} e_t;
module top(output e_t o);
  assign o = D;
endmodule
