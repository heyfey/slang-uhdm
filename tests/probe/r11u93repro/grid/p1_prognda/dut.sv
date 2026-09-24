// r11u92 p1 -- a PROGRAM home with a net-declaration assignment, no strength.
program prg ();
  wire [31:0] w_plain = 32'd11;
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
