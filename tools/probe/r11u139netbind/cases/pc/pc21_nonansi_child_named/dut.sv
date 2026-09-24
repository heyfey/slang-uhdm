module sub(a, b, y); input a, b; output y; assign y = a ^ b; endmodule
module top(input p, input q, output y);
  sub u(.a(p & q), .b(q | p), .y(y));
endmodule
