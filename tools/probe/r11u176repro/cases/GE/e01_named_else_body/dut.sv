// § genElseBeginIfDepth176
module dut(input a, b, output c);
  parameter p = 2;
  if (p == 1) begin
    and g0(c, a, b);
  end else begin : eb
    if (p == 2) begin
      xor g1(c, a, b);
    end
  end
endmodule
