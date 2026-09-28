// § splitPortRealRedeclLogicTs191: a realtime-free mix: real input, shortreal output, integer output (control), in one module
module dut(a, b, c);
  input a;
  output b;
  output c;
  real a;
  shortreal b;
  integer c;
  always @(*) begin b = a; c = 1; end
endmodule
