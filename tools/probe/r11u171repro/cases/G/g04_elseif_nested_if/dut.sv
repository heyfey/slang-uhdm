// § genElseIfGateTermPath171
module dut(input a, b, output c, d);
  parameter p = 2;
  if (p == 1)
    begin : u0
      and g0(c, a, b);
    end
  else if (p == 2) begin
    if (1) begin
      xnor g4(c, a, b);
    end
    if (1) begin : n5
      xnor g5(d, a, b);
    end
  end
endmodule
