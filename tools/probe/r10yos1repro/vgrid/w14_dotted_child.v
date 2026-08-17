module \c.h.D (input wire a, output wire b);
  assign b = a;
endmodule

module \a.b.C (input wire x, output wire y);
  \c.h.D c1 (.a(x), .b(y));
endmodule
