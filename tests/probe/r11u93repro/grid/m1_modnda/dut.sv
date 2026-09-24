// r11u92 m1 -- THE MODULE CONTROL: the same nda in a module home keeps its cell.
module sub ();
  wire [31:0] w_plain = 32'd11;
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
