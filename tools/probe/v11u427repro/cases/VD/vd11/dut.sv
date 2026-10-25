// § ovUntypedTsDeclWidth427
module sub #(parameter P = 'b1) (output [7:0] o);
  assign o = P;
endmodule
module top(output [7:0] o);
  sub u(o);
endmodule
