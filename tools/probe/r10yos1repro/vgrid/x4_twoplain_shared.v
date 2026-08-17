module child (input wire a, output wire b);
  assign b = a;
endmodule

module p1 (input wire x, output wire y);
  child c1 (.a(x), .b(y));
endmodule

module p2 (input wire x, output wire y);
  child c2 (.a(x), .b(y));
endmodule
