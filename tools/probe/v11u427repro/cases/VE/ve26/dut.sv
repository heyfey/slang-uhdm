// § elabUnszXzTypedAdjust427
module sub #(parameter logic [7:0] P = 'b1x) (output [7:0] o);
  assign o = P;
endmodule
module top(output [7:0] o, o2);
  sub u(o);
  sub #(.P(8'h3)) u2(o2);
endmodule
