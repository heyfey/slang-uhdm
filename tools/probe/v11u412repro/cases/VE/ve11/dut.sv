// § enumXzReplInitZero412
module top(output logic [3:0] o);
  enum logic [3:0] {A = 4'd1, X = {4{1'Bx}}} v;
  assign v = A;
  assign o = v;
endmodule
