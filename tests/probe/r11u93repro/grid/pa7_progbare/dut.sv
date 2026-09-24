// r11u93 pa7 -- a BARE named generate block (no if) in a program.
program prg ();
  wire [31:0] w_plain = 32'd11;
  generate
    begin : g
      wire [31:0] w_bare = 32'd12;
    end
  endgenerate
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
