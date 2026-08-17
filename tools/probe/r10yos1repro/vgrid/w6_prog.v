program \p.r.G ();
  initial $display("hi");
endprogram

module plaintop (input wire x, output wire y);
  assign y = x;
endmodule
