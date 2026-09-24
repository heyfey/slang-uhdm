// r11u90 u10 -- LAW A in a PROGRAM home.
program prg ();
  wire [31:0] w_plain = 32'd11;
  wire (strong1, weak0) [31:0] w_str = 32'd12;
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
