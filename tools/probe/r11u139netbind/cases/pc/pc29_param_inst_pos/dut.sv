// § connLeftmostLeafElab139
module sub #(parameter W = 1) (input c, input a, output y); assign y = a ^ c; endmodule
module top(input c, input p, input q, output y);
  sub #(1) u(c, p & q, y);
endmodule
