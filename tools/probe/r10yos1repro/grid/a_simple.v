module child (input wire a, output wire b);
  assign b = a;
endmodule

module top (input wire x, output wire y);
  child c1 (.a(x), .b(y));
endmodule
