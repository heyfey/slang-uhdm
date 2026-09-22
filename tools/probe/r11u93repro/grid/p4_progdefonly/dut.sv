// r11u92 p4 -- the PROGRAM is never instantiated: the DEFINITION view alone.
program prg ();
  wire [31:0] w_nda = 32'd11;
  wire [31:0] w_ca;
  assign w_ca = 32'd12;
endprogram
module dut (output logic [31:0] o);
  assign o = 32'd0;
endmodule
