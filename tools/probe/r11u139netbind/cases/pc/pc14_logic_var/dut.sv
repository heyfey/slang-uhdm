module sub(input a, input b, output y); assign y = a ^ b; endmodule
module top(input p, output y);
  logic l;
  assign l = p;
  sub u(.a(l | p), .b(p | l), .y(y));
endmodule
