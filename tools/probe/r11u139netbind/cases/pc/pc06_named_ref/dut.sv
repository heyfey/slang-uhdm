module sub(input a, input b, output y); assign y = a ^ b; endmodule
module top(input p, input q, output y);
  sub u(.a(p), .b(q), .y(y));
endmodule
