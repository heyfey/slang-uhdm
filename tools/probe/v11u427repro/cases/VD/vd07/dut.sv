// § ovUntypedTsDeclWidth427
module sub #(parameter P = 4'b1) (output [7:0] o);
  assign o = P;
endmodule
module top(output [7:0] o);
  localparam Q = 8'hF0;
  sub #(.P(Q)) u(o);
endmodule
