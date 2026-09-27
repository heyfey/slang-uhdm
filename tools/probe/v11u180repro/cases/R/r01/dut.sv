// § splitPortIntRedeclLogicTs180 (verifier: the integer declared before the port declaration)
module dut (a, b);
  input  [3:0] a;
  integer b;
  output b;
  always @(*) b = a;
endmodule
