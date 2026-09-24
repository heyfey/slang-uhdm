module mon (input wire a);
  initial $display("%b", a);
endmodule

module \a.b.C (input wire x, output wire y);
  assign y = x;
endmodule

bind \a.b.C mon m1 (.a(x));
