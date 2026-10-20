// § stdRandomizeFuncCall413
module top;
  int a;
  int ok;
  initial ok = randomize(a) with { a < 10; };
endmodule
