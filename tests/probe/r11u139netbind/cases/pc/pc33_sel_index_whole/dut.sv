// § connLeftmostLeafElab139
module sub(input a, input b, output y); assign y = a ^ b; endmodule
module top(input [1:0] idx, input [3:0] v, input p, output y);
  sub u(.a(v[idx]), .b(p), .y(y));
endmodule
