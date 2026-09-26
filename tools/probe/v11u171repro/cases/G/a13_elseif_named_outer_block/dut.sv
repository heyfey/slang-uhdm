// § genElseIfGateTermPath171
module dut(input a, b, output c);
  parameter p = 2;
  if (1) begin : top
    if (p == 1)
      and g0(c, a, b);
    else if (p == 2) begin
      xor g1(c, a, b);
    end
  end
endmodule
