module sub(input a, input b, output y); assign y = a ^ b; endmodule
module top(a, b, y);
  input a, b; output y;
  wire a, b;
  sub u(a && !b, !a && b, y);
endmodule
