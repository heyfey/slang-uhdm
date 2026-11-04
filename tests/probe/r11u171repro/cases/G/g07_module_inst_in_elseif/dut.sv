// § genElseIfGateTermPath171
module leaf(input a, b, output c); assign c = a ^ b; endmodule
module dut(input a, b, output c);
  parameter p = 2;
  if (p == 1) begin : u0
    and g0(c, a, b);
  end
  else if (p == 2) begin
    leaf l1(a, b, c);
  end
endmodule
