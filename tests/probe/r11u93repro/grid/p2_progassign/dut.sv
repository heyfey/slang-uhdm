// r11u92 p2 -- a PROGRAM home with a WRITTEN continuous assignment.
program prg ();
  wire [31:0] w_plain;
  assign w_plain = 32'd11;
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
