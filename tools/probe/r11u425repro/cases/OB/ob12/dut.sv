// § oneTickUpperBNormalized425
module sub #(parameter P = 1'b0)(input a, output o); assign o = a ^ P; endmodule
module top(input a, output o, output p);
  sub #(.P(1'B1)) u1(.a(a), .o(o));
  sub #(1'BX) u2(.a(a), .o(p));
endmodule
