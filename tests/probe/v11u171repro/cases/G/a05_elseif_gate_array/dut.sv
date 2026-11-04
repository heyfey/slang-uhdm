// § genElseIfGateTermPath171
module dut(input [1:0] a, b, output [1:0] c);
  parameter p = 2;
  if (p == 1) begin : n
    and g0 [1:0] (c, a, b);
  end else if (p == 2) begin
    xor g1 [1:0] (c, a, b);
  end
endmodule
