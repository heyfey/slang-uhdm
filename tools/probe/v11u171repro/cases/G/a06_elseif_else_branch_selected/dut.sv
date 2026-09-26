// § genElseIfGateTermPath171
module dut(input a, b, output c);
  parameter p = 3;
  if (p == 1) begin
    and g0(c, a, b);
  end else if (p == 2) begin
    xor g1(c, a, b);
  end else begin
    nand g2(c, a, b);
  end
endmodule
