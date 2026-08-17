module child (input wire a, output wire b);
  assign b = a;
endmodule

module plaintop (input wire x, output wire y);
  child c2 (.a(x), .b(y));
endmodule
