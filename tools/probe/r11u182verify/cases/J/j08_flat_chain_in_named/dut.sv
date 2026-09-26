// § genElseIfGateTermPath171 § genElseIfFlatOnly171v
module dut #(parameter int P = 2) (input a, b, output c);
  if (1) begin : outer
    if (P == 1)
      and g0 (c, a, b);
    else if (P == 2)
      xor g1 (c, a, b);
    else
      or g2 (c, a, b);
  end
endmodule
