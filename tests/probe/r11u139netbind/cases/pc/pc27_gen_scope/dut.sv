// § connLeftmostLeafElab139
module sub(input a, input b, output y); assign y = a ^ b; endmodule
module top(input p, input q, output y);
  if (1) begin : g
    sub u(.a(p & q), .b(q | p), .y(y));
  end
endmodule
