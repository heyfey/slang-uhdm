// § ovUntypedTsDeclWidth427
module sub #(parameter P = 'h7) (output [7:0] o);
  assign o = P;
endmodule
module top(output [7:0] o);
  sub #(.P(4'b1001)) u(o);
endmodule
