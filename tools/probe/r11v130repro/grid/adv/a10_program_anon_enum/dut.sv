// § defNetEndOnlyLoc130
program prg;
  enum {A, B, C} x;
  initial x = B;
endprogram
module top;
  prg p();
endmodule
