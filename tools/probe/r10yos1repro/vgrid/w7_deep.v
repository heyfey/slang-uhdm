module leaf (input wire a, output wire b);
  assign b = ~a;
endmodule

module mid (input wire a, output wire b);
  leaf l1 (.a(a), .b(b));
endmodule

module \a.b.C (input wire x, output wire y);
  mid m1 (.a(x), .b(y));
endmodule
