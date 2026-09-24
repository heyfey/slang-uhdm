module sub (input wire a, output wire b);
  logic inner;
  assign inner = a;
  assign b = inner;
endmodule

module \a.b.C (input wire x, output wire y);
  sub s1 (.a(x), .b(y));
  wire probe = s1.inner;
endmodule
