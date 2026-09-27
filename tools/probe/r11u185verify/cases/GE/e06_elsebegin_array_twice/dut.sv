// § genElseIfGateArrayPath176 § genElseBeginIfDepth176
module dut(input [3:0] a, b, output [3:0] c);
  parameter p = 2;
  if (p == 1) begin
    buf g0 [3:0] (c, a);
  end else begin
    wire [3:0] t;
    if (p == 2) begin
      and g1 [3:0] (t, a, b);
      not g2 [3:0] (c, t);
    end else begin
      or g3 [3:0] (t, a, b);
      buf g4 [3:0] (c, t);
    end
  end
endmodule
module top(input [3:0] a, b, output [3:0] c2, c3);
  dut #(2) u2(a, b, c2);
  dut #(5) u3(a, b, c3);
endmodule
