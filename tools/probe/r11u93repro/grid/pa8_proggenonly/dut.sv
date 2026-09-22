// r11u93 pa8 -- a program whose ONLY net is inside the generate block.
program prg ();
  generate
    if (1) begin : g
      wire [31:0] w_gen = 32'd12;
    end
  endgenerate
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
