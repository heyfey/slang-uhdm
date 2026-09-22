// r11u93 pa2 -- a program generate block on an UNTAKEN if.
program prg ();
  wire [31:0] w_plain = 32'd11;
  generate
    if (0) begin : g
      wire [31:0] w_gen = 32'd12;
    end
  endgenerate
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
