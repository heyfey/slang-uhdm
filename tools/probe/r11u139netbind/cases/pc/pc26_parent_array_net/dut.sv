// § connLeftmostLeafElab139
module sub(input a, input b, output y); assign y = a ^ b; endmodule
module top(input p, output y);
  wire w [1:0];
  assign w[0] = p; assign w[1] = p;
  sub u(.a(w[0] & p), .b(p), .y(y));
endmodule
