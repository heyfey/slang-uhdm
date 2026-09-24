// § defNetEndOnlyLoc130
module sub(p, q);
  input p;
  output q;
  wire p;
  enum logic [1:0] {A, B} q;
  assign q = p ? A : B;
endmodule
module top(input logic i, output logic [1:0] o);
  sub u(.p(i), .q(o));
endmodule
