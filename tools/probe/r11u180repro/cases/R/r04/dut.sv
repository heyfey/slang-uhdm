// § splitPortIntRedeclLogicTs180
module dut (a, b);
  input  [3:0] a;
  output signed b;
  integer b;
  always @(*) b = a;
endmodule
