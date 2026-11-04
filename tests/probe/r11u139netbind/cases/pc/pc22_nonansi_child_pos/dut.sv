// § connLeftmostLeafElab139
module sub(a, b, y); input a, b; output y; assign y = a ^ b; endmodule
module top(input p, input q, output y);
  sub u(p & q, q | p, y);
endmodule
