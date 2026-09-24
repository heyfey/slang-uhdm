module sub(input c, input a, output y); assign y = a ^ c; endmodule
module top(input [1:0] v, input p, input q, output y);
  sub u(v[0], p & q, y);
endmodule
