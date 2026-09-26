// § genElseIfFlatOnly171v
module m #(parameter P = 0) (input a, b, output c);
  if (P == 1)
    and g0(c, a, b);
  else if (P == 2)
    xor g1(c, a, b);
  else if (P == 3)
    or g2(c, a, b);
endmodule
module dut(input a, b, output c2, c3);
  m #(2) i2(a, b, c2);
  m #(3) i3(a, b, c3);
endmodule
