// § genElseBeginIfDepth176
module dut(input a, b, output c);
  parameter p = 2;
  if (p == 1) begin
    and g0(c, a, b);
  end else begin
    if (p == 3) begin
      or g2(c, a, b);
    end else begin
      xor g1(c, a, b);
    end
  end
endmodule
