// § genElseBeginIfDepth176
module dut(input a, b, output c, d);
  parameter p = 2;
  if (p == 1) begin
    and g0(c, a, b);
  end else begin
    if (p == 2) begin
      or g1(c, a, b);
    end
    nand g9(d, a, b);
  end
endmodule
