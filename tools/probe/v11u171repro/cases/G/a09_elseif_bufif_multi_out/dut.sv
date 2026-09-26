// § genElseIfGateTermPath171
module dut(input a, en, output c, d);
  parameter p = 2;
  if (p == 1) begin
    buf g0(c, d, a);
  end else if (p == 2) begin
    buf g1(c, d, a);
    bufif1 g2(c, a, en);
  end
endmodule
