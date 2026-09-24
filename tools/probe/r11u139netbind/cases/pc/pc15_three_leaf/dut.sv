module sub(input a, input b, output y); assign y = a ^ b; endmodule
module top(input p, input q, input r, output y);
  sub u(.a(p & q & r), .b((p | q) & r), .y(y));
endmodule
