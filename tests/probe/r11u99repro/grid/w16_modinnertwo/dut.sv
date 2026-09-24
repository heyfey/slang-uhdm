// TWO nested module declarations, out of alphabetical order
module sub ();
  module zmod (); wire [31:0] z = 32'd1; endmodule
  module amod (); wire [31:0] a = 32'd2; endmodule
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
