// § enumRangedMemberSurelogVal412
module top(input logic clk, output logic y);
  enum {A, B=5, C} s;
  always_ff @(posedge clk) s <= C;
  assign y = (s == C);
endmodule
