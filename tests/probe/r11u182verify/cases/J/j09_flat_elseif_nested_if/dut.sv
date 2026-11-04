// § genElseIfGateTermPath171 § genElseIfFlatOnly171v
module dut #(parameter int P = 2, parameter int Q = 1) (input a, b, output c);
  if (P == 1)
    and g0 (c, a, b);
  else if (P == 2)
    if (Q == 1)
      nand g1 (c, a, b);
    else
      nor g2 (c, a, b);
endmodule
