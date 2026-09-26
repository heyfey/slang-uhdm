// § genElseBeginIfDepth176
module dut #(parameter P = 2) (input a, b, output c);
  if (P == 1) begin
    assign c = a;
  end else begin
    if (P == 2) or g1 (c, a, b);
  end
endmodule
