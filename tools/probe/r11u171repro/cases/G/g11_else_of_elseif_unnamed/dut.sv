// § genElseIfGateTermPath171
module dut(input a, b, output c);
  parameter p = 3;
  if (p == 1) begin : u0
    and g0(c, a, b);
  end
  else if (p == 2) begin : u1
    or g1(c, a, b);
  end
  else begin
    xor g2(c, a, b);
  end
endmodule
