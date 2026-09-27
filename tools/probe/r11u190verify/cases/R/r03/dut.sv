// § splitPortIntRedeclLogicTs180 (r11u190: the split integer-port module instantiated in a generate loop and a generate if)
module sub(a, b);
  input [3:0] a;
  output b;
  integer b;
  always @(*) b = a + 1;
endmodule
module top(input [3:0] a, output [1:0] o, output p);
  for (genvar g = 0; g < 2; g++) begin : G
    sub u(a, o[g]);
  end
  if (1) begin : H
    sub v(a, p);
  end
endmodule
