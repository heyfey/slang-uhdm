// § ovUntypedTsDeclWidth427
module sub #(P = 3'b101) (output [7:0] o);
  assign o = P;
endmodule
module top(output [7:0] o);
  sub #(5'b10101) u(o);
endmodule
