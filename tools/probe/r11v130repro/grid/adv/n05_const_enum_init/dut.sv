// § defNetEndOnlyLoc130
module top(output logic [1:0] o);
  const enum logic [1:0] {A, B} x = B;
  assign o = x;
endmodule
