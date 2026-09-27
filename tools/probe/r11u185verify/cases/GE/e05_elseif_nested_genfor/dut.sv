// § genElseIfGateArrayPath176 § genElseBeginIfDepth176
module dut(input [1:0] a, b, output [1:0] c);
  parameter p = 2;
  if (p == 1) begin
    and g0 [1:0] (c, a, b);
  end else if (p == 2) begin
    for (genvar i = 0; i < 2; i++) begin : L
      or gi(c[i], a[i], b[i]);
    end
  end else begin
    for (genvar j = 0; j < 2; j++) begin
      xor gj(c[j], a[j], b[j]);
    end
  end
endmodule
module top(input [1:0] a, b, output [1:0] c2, c3);
  dut #(2) u2(a, b, c2);
  dut #(3) u3(a, b, c3);
endmodule
