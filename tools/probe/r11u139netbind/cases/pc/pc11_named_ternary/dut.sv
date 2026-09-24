module sub(input a, input b, output y); assign y = a ^ b; endmodule
module top(input s, input p, input q, output y);
  sub u(.a(s ? p : q), .b(q), .y(y));
endmodule
