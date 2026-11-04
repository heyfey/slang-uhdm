// § genElseIfGateTermPath171
module dut #(parameter int P = 2) (input a, b, output c, d);
  if (P == 1)
    and g0 (c, a, b);
  else if (P == 2) begin
    or g1 (c, a, b);
    xor g2 (d, a, b);
  end
endmodule
