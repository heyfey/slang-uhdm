// r11u93 pa6 -- NESTED generate blocks in a program.
program prg ();
  wire [31:0] w_plain = 32'd11;
  generate
    if (1) begin : g
      wire [31:0] w_out = 32'd12;
      if (1) begin : h
        wire [31:0] w_in = 32'd13;
      end
    end
  endgenerate
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
