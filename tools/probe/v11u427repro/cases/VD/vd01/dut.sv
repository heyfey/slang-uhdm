// § ovUntypedTsDeclWidth427
module sub #(parameter P = (4'b1001)) (output [7:0] o);
  assign o = P;
endmodule
module top(output [7:0] o);
  sub u(o);
endmodule
