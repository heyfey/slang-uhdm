// r11u92 p9 -- a VARIABLE initializer (not a net) in a PROGRAM home.
program prg ();
  logic [31:0] v_init = 32'd11;
  wire [31:0] w_nda = 32'd12;
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
