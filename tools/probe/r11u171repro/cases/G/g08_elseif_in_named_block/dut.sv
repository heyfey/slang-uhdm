// § genElseIfGateTermPath171
module dut(input a, b, output c);
  parameter p = 2;
  if (1) begin : outer
    if (p == 1) begin : u0
      and g0(c, a, b);
    end
    else if (p == 2) begin
      xor g1(c, a, b);
    end
  end
endmodule
