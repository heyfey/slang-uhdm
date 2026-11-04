// § genElseIfGateTermPath171
module dut(input a, b, output c);
  parameter p = 2, q = 3;
  if (p == 1)
    and g0(c, a, b);
  else if (p == 2)
    if (q == 3) begin
      xor g2(c, a, b);
    end
endmodule
