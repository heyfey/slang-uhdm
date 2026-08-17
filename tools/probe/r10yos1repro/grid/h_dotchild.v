module \a.b.C (input wire a, output wire b);
  assign b = a;
endmodule

module top (input wire x, output wire y);
  \a.b.C c1 (.a(x), .b(y));
endmodule
