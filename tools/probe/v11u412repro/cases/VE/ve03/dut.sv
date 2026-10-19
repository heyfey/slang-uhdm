// § enumRangedMemberSurelogVal412
module top(output logic [31:0] o);
  parameter enum {X=2, Y} P = Y;
  assign o = P;
endmodule
