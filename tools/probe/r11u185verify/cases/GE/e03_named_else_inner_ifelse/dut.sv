// § genElseBeginIfDepth176
module dut(input a, b, output c);
  parameter p = 3;
  if (p == 1) begin
    and g0(c, a, b);
  end else begin : nb
    if (p == 2) begin
      or g1(c, a, b);
    end else begin
      xnor g2(c, a, b);
    end
  end
endmodule
