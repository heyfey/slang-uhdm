// § genElseIfGateTermPath171
module m #(parameter P = 0) (input a, b, output c);
  if (P == 0) begin : z
    and g0(c, a, b);
  end else if (P == 1) begin
    xor g1(c, a, b);
  end else begin
    or g2(c, a, b);
  end
endmodule
module dut(input a, b, output c0, c1, c2);
  m #(0) i0(a, b, c0);
  m #(1) i1(a, b, c1);
  m #(2) i2(a, b, c2);
endmodule
