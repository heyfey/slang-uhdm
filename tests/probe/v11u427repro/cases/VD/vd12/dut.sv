// § ovTsDeclParenUnszAbstain427v
module sub #(parameter P = (4'b1001)) (output [7:0] o);
  assign o = P;
endmodule
module top(output [7:0] o);
  sub #(.P(4'b0110)) u(o);
endmodule
