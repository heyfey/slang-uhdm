module amod ();
  module mid (output logic m); module deep (); wire d; endmodule assign m = 1'b0; endmodule
endmodule
module bmod ();
  module mid (); module deep (output logic e); assign e = 1'b1; endmodule wire n; endmodule
endmodule
module dut (output logic [31:0] o);
  amod u_a ();
  bmod u_b ();
  assign o = 32'd0;
endmodule
