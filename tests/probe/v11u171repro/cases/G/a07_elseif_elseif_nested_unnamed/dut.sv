// § genElseIfGateTermPath171
module dut(input a, b, output c);
  parameter p = 2, q = 3;
  if (p == 1) begin
    and g0(c, a, b);
  end else if (p == 2) begin
    if (q == 1) begin
      or g1(c, a, b);
    end else if (q == 3) begin
      xor g2(c, a, b);
    end
  end
endmodule
