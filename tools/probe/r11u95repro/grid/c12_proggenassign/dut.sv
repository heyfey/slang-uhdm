// r11u95 c12 -- THE PASS-93 CONTROL: a standalone assign in a program gen block.
program prg ();
  wire [31:0] w_plain = 32'd11;
  wire [31:0] w_gen;
  generate
    if (1) begin : g
      assign w_gen = 32'd12;
    end
  endgenerate
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
