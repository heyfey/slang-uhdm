// § ovUntypedTsDeclWidth427
`define W 4'b1001
module sub #(parameter P = `W) (output [7:0] o);
  assign o = P;
endmodule
module top(output [7:0] o);
  sub #(.P(2'b11)) u(o);
endmodule
