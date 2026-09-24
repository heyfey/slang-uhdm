module mon (input wire a);
  initial $display("mon %b", a);
endmodule

module \a.b.C (input wire x, output wire y);
  assign y = x;
  bind \a.b.C mon m1 (.a(x));
endmodule
