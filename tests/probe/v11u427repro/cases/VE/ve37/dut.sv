// § elabBasedLitLowerBase427
module sub #(parameter P = 8'HAB) (output [7:0] o);
  assign o = P;
endmodule
module top(output [7:0] o, o2);
  sub u(o);
  sub u2(o2);
endmodule
