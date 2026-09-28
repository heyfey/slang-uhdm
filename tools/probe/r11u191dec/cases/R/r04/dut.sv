// (r11u191 split real port) control: a split port declared with a range (not data-typeless) and redeclared as a variable
module dut(a, b);
  input [3:0] a;
  output [3:0] b;
  reg [3:0] b;
  always @(*) b = a;
endmodule
