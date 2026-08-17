module child (input wire a, output wire b);
  assign b = a;
endmodule

module top1 (input wire x, output wire y);
  child c1 (.a(x), .b(y));
endmodule

module top2 (input wire x, output wire y);
  child c2 (.a(x), .b(y));
endmodule
