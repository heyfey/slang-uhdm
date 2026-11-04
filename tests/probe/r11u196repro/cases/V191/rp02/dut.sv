// § splitPortRealRedeclLogicTs191: a real input and a real output of a child instantiated twice
module sub(p, q);
  input p;
  output q;
  real p;
  real q;
  always @(*) q = p * 2.0;
endmodule
module top(input x, output y, output z);
  sub u1(.p(x), .q(y));
  sub u2(.p(x), .q(z));
endmodule
