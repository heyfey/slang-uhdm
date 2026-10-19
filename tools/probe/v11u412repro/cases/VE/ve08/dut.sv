// § enumRangedMemberSurelogVal412
typedef enum {A[2] = 5, B} e_t;
module top(output logic [31:0] o);
  assign o = B;
endmodule
