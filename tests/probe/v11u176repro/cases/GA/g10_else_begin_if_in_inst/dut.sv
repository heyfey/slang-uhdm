// § genElseBeginIfDepth176
module sub #(parameter P = 2) (input a, b, output c);
  if (P == 1) begin
    assign c = a;
  end else begin
    if (P == 2) begin
      and g1 (c, a, b);
    end else begin
      or g2 (c, a, b);
    end
  end
endmodule
module dut (input a, b, output c, d);
  sub #(.P(2)) u1 (a, b, c);
  sub #(.P(3)) u2 (a, b, d);
endmodule
