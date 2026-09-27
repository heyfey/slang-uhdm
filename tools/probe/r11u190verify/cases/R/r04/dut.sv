// § splitPortIntRedeclLogicTs180 (r11u190: part-select and bit-select writes of the integer-redeclared port, an input redeclared integer)
module dut(a, b, c, k);
  input [3:0] a;
  input k;
  output b;
  output c;
  integer b;
  integer c;
  integer k;
  always @(*) begin
    b = 0;
    b[3:0] = a;
    b[7:4] = ~a;
    c = 0;
    c[k] = a[0];
    c[2+:2] = a[1:0];
  end
endmodule
