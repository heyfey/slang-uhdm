module sub(input a, input b, output y); assign y = a ^ b; endmodule
module top(p, q, y);
  input p, q; output y;
  wire p, q;
  sub u(.a(p & q), .b(q), .y(y));
endmodule
