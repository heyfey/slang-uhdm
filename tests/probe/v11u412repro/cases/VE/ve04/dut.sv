// § enumRangedMemberSurelogVal412
module top(output logic [2:0] o);
  struct packed { enum logic [1:0] {Q=1, R} f; logic g; } s;
  assign s = 3'b101;
  assign o = s;
endmodule
