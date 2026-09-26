// § genElseIfFlatOnly171v
module dut(input a, b, output c);
  parameter p = 2;
  if (p == 1)
    and g0(c, a, b);
  else if (p == 2)
    xor g1(c, a, b);
endmodule
