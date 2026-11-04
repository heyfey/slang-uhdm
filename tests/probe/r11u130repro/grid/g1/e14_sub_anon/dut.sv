// § defNetEndOnlyLoc130
module sub;
  enum logic [2:0] {S0, S1, S2} st;
  enum {T0, T1} tt;
  initial begin st = S1; tt = T1; end
endmodule
module top;
  sub u1();
  sub u2();
endmodule
