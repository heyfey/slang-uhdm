// § ovTsDeclParenUnszAbstain427v
module sub #(parameter P = ((2'b10))) (output [7:0] o);
  assign o = P;
endmodule
module top(output [7:0] o, output [7:0] o2);
  sub u(o);
  sub #(.P(6'd5)) u2(o2);
endmodule
