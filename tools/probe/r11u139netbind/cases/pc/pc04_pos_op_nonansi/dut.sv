module sub(input a, input b, output y); assign y = a ^ b; endmodule
module top(p, q, y);
  input p, q; output y;
  wire p, q;
  sub u(p && !q, !p && q, y);
endmodule
