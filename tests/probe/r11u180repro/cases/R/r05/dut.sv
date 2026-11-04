// § splitPortIntRedeclLogicTs180
module dut (a, b);
  input  [3:0] a;
  output reg b;
  always @(*) b = a[0];
endmodule
