// § typedLitElabAdjustLogic427
module sub #(parameter logic [7:0] P = 4'hA) (output [7:0] o);
  assign o = P;
endmodule
module top(output [7:0] o, o2);
  sub u(o);
  sub #(.P(8'h11)) u2(o2);
endmodule
