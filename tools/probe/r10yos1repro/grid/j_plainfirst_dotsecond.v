module child (input wire a, output wire b);
  assign b = a;
endmodule

module plaintop (input wire x, output wire y);
  child c2 (.a(x), .b(y));
endmodule

module \a.b.C (input wire x, output wire y);
  child c1 (.a(x), .b(y));
endmodule
