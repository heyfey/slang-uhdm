// § genElseBeginIfDepth176
module dut #(parameter P = 3) (input a, b, output c);
  if (P == 1) begin
    assign c = a;
  end else begin
    if (P == 2) begin
      assign c = b;
    end else begin
      nand g1 (c, a, b);
    end
  end
endmodule
