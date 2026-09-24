module sub(input a, input b, output y); assign y = a ^ b; endmodule
module top(input a, input b, output y);
  sub u(.a(a & b), .b(b | a), .y(y));
endmodule
