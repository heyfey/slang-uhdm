// § ovUntypedTsDeclWidth427
module sub #(parameter P = 'h7) (input a, output o);
  assign o = a ^ P[0];
endmodule
module top(input a, output o);
  sub #(.P(4'b1001)) u(.a(a), .o(o));
endmodule
