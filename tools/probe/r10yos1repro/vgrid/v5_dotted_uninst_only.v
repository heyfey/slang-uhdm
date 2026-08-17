module \a.b.C (input wire x, output wire y);
  assign y = x;
endmodule

module plaintop (input wire x, output wire y);
  assign y = ~x;
endmodule
