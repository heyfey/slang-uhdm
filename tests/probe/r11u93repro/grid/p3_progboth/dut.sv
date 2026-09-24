// r11u92 p3 -- a PROGRAM home with BOTH a net-decl assignment and a written one.
program prg ();
  wire [31:0] w_nda = 32'd11;
  wire [31:0] w_ca;
  assign w_ca = 32'd12;
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
