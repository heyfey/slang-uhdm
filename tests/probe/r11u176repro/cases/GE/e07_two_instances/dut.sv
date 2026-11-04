// § genElseBeginIfDepth176
module sub #(parameter p = 2) (input a, b, output c);
  if (p == 1) begin
    and g0(c, a, b);
  end else begin
    if (p == 2) begin
      xor g1(c, a, b);
    end
  end
endmodule
module dut(input a, b, output c, d);
  sub #(2) u1(a, b, c);
  sub #(1) u2(a, b, d);
endmodule
