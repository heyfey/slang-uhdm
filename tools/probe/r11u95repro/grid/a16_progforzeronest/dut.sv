// r11u95 a16 -- LOOP BOUND 0 whose block holds a NESTED block with a net.
program prg ();
  wire [31:0] w_plain = 32'd11;
  generate
    for (genvar i = 0; i < 0; i++) begin : g
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
