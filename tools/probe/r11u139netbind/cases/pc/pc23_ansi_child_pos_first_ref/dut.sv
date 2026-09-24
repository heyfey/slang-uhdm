module sub(input c, input a, input b, output y); assign y = a ^ b ^ c; endmodule
module top(input c, input p, input q, output y);
  sub u(c, p & q, q | p, y);
endmodule
