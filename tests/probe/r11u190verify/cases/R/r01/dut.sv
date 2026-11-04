// § splitPortIntRedeclLogicTs180 (r11u190: integer, time, real and byte redeclarations of four data-typeless outputs)
module dut(a, b, c, d, e);
  input [3:0] a;
  output b;
  output c;
  output d;
  output e;
  integer b;
  time c;
  real d;
  byte e;
  always @(*) begin
    b = a;
    c = a;
    d = a;
    e = a;
  end
endmodule
