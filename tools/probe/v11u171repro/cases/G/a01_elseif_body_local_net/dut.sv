// § genElseIfGateTermPath171
module dut(input a, b, output c, d);
  parameter p = 2;
  if (p == 1) begin : u0
    and g0(c, a, b);
  end else if (p == 2) begin
    wire t;
    xor g1(t, a, b);
    or g2(c, t, a);
    assign d = t;
  end
endmodule
