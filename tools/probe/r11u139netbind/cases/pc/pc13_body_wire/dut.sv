// § connLeftmostLeafElab139
module sub(input a, input b, output y); assign y = a ^ b; endmodule
module top(input p, output y);
  wire w = p;
  sub u(.a(w & p), .b(p & w), .y(y));
endmodule
