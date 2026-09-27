// § splitPortIntRedeclLogicTs180
module dut (a, b, c);
  input  [3:0] a;
  output b, c;
  integer b;
  byte c;
  always @(*) begin b = a; c = a; end
endmodule
