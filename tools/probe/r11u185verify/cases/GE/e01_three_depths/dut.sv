// § genElseBeginIfDepth176
module dut(input a, b, output c);
  parameter p = 4;
  if (p == 1) begin
    and g0(c, a, b);
  end else begin
    if (p == 2) begin
      or g1(c, a, b);
    end else begin
      if (p == 3) begin
        nand g2(c, a, b);
      end else begin
        if (p == 4) begin
          xor g3(c, a, b);
        end
      end
    end
  end
endmodule
