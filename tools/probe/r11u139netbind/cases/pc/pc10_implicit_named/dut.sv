module sub(input a, input b, output y); assign y = a ^ b; endmodule
module top(input a, input b, output y);
  sub u(.a, .b, .y);
endmodule
