// § genElseIfGateArrayPath176 § genElseBeginIfDepth176
module dut(input [1:0] a, b, output [1:0] c);
  parameter p = 2;
  if (p == 1) begin
    and g0 [1:0] (c, a, b);
  end else begin
    if (p == 2) begin
      or g1 [1:0] (c, a, b);
    end else begin
      xor g2 [1:0] (c, a, b);
    end
  end
endmodule
module top(input [1:0] a, b, output [1:0] c1, c2, c3);
  dut #(1) u1(a, b, c1);
  dut #(2) u2(a, b, c2);
  dut #(3) u3(a, b, c3);
endmodule
