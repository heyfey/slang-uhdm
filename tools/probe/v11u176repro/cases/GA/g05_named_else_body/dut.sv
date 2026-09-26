// § genElseBeginIfDepth176
module dut #(parameter P = 2) (input a, b, output c);
  if (P == 1) begin
    assign c = a;
  end else begin : nb
    if (P == 2) begin
      and g1 (c, a, b);
    end
  end
endmodule
