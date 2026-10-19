// § enumRangedMemberSurelogVal412
module top();
  enum {X=3, Y} v = Y;
  enum {S[2], T} u;
  initial begin
    u = S1;
    v = X;
  end
endmodule
