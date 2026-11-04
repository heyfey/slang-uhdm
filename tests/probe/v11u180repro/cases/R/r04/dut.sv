// § splitPortIntRedeclLogicTs180 (verifier: an input redeclared as a net of integer type is not touched; output int)
module dut (a, b);
  input a;
  output b;
  wire a;
  int b;
  always @(*) b = a;
endmodule
