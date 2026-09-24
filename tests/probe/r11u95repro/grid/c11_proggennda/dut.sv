// r11u95 c11 -- THE PASS-93 CONTROL: a net-decl-assign in a program gen block.
program prg ();
  wire [31:0] w_plain = 32'd11;
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
