module child (input wire a, output wire b);
  assign b = a;
endmodule

module \a[0] (input wire x, output wire y);
  child c1 (.a(x), .b(y));
endmodule
