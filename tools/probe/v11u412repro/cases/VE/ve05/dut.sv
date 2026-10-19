// § enumRangedMemberSurelogVal412
module top #(parameter P = 3) (output logic [31:0] o);
  typedef enum {A=P, B} e_t;
  e_t v;
  assign v = B;
  assign o = v;
endmodule
