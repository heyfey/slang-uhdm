// § genElseIfGateTermPath171
module dut(input a, b, output c, d);
  parameter p = 2;
  if (p == 2) begin
    xor g1(c, a, b);
    assign d = a | b;
  end
endmodule
