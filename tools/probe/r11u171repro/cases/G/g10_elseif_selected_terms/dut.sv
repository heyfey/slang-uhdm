// § genElseIfGateTermPath171
module dut(input [1:0] a, input b, output [1:0] c);
  parameter p = 2;
  if (p == 1) begin : u0
    and g0(c[0], a[0], b);
  end
  else if (p == 2) begin
    xor g1(c[0], a[1], b);
    not g2(c[1], a[0]);
  end
endmodule
