module childa (input wire a, output wire b);
  assign b = a;
endmodule

module childb (input wire a, output wire b);
  assign b = ~a;
endmodule

module \a.b.C (input wire x, output wire y);
  childa c1 (.a(x), .b(y));
endmodule

module plaintop (input wire x, output wire y);
  childb c2 (.a(x), .b(y));
endmodule
