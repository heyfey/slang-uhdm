// § ovTsDeclParenUnszAbstain427v
module sub #(parameter P = 'b1) (output [7:0] o);
  assign o = P;
endmodule
module top(output [7:0] o);
  sub #(.P(4'b1010)) u(o);
endmodule
