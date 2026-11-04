// § splitPortRealRedeclLogicTs191: realtime and shortreal inputs, a real output driven by a continuous assignment
module dut(a, b, c);
  input a;
  input b;
  output c;
  realtime a;
  shortreal b;
  real c;
  assign c = a + b;
endmodule
module top(output real y);
  realtime t = 1.5;
  shortreal s = 2.0;
  dut u(.a(t), .b(s), .c(y));
endmodule
