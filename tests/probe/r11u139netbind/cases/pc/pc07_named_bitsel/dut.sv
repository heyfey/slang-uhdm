// § connLeftmostLeafElab139
module sub(input a, input b, output y); assign y = a ^ b; endmodule
module top(input [1:0] v, input q, output y);
  sub u(.a(v[0]), .b(v[1] | q), .y(y));
endmodule
