// § genElseBeginIfDepth176
module dut #(parameter P = 2, parameter Q = 1) (input a, b, output c);
  if (P == 1) begin
    assign c = a;
  end else begin
    if (P == 2) begin
      if (Q == 1) begin
        and g1 (c, a, b);
      end
    end
  end
endmodule
