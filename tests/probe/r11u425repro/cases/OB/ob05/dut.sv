// § oneTickUpperBNormalized425
module sub(input i, output o); assign o = i; endmodule
module top(output o, output p);
  sub u1(.i(1'B1), .o(o));
  sub u2(.i(1'B0), .o(p));
endmodule
