// § genElseIfGateTermPath171 § genElseIfFlatOnly171v
module dut #(parameter int P = 3) (input [1:0] a, b, input x, y, output [1:0] c, output z);
  if (P == 1)
    and g0 [1:0] (c, a, b);
  else if (P == 2)
    or g1 [1:0] (c, a, b);
  else if (P == 3)
    xor g2 (z, x, y);
endmodule
