// § connLeftmostLeafElab139
module sub(input a, input b, output y); assign y = a ^ b; endmodule
module top(p, q, y);
  input p, q; output y;
  sub u(.a(p & q), .b(q | p), .y(y));
endmodule
