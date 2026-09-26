// § genElseIfGateTermPath171
module sub #(parameter int P = 2) (input a, b, output c);
  if (P == 1) begin
    buf g0 (c, a);
  end else if (P == 2) begin
    and g1 (c, a, b);
  end else if (P == 3) begin
    or g2 (c, a, b);
  end
endmodule
module dut (input a, b, output c, d, e);
  sub #(.P(1)) u1(a, b, c);
  sub #(.P(2)) u2(a, b, d);
  sub #(.P(3)) u3(a, b, e);
endmodule
