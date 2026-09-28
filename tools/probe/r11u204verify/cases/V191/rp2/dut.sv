// § splitPortRealRedeclLogicTs191: two ports in one direction declaration redeclared real and realtime, a parameterized module instantiated twice
module dut #(parameter int K = 1) (a, b, c);
  input a, b;
  output c;
  real a;
  realtime b;
  real c;
  always @(*) c = a * K + b;
endmodule
module top(output real y1, y2);
  real r = 1.0;
  realtime q = 2.0;
  dut #(2) u1(.a(r), .b(q), .c(y1));
  dut #(3) u2(.a(r), .b(q), .c(y2));
endmodule
