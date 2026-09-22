// r11u93 pa11 -- a net declared DIRECTLY in a generate region, no block.
program prg ();
  wire [31:0] w_plain = 32'd11;
  generate
    wire [31:0] w_reg = 32'd12;
  endgenerate
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
