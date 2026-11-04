// § ovUntypedTsDeclWidth427
module sub #(parameter P = 8) (output [7:0] o);
  assign o = P;
endmodule
module top(output [7:0] o);
  sub #(.P(4'b1010)) u(o);
endmodule
