module sub #(parameter P = 1) (input p, output a, output b, output c);
  assign a = P;
  assign b = p & P;
  assign c = p;
endmodule
module top(input i, output x, output y, output z);
  sub #(.P(1)) u(.p(i), .a(x), .b(y), .c(z));
endmodule
