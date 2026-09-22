// v11u93 v13 -- TWO generate blocks in a PROGRAM, body net between them.
program prg ();
  generate
    if (1) begin : g1
      wire [31:0] w_a = 32'd12;
    end
  endgenerate
  wire [31:0] w_mid = 32'd11;
  generate
    if (1) begin : g2
      wire [31:0] w_b = 32'd13;
    end
  endgenerate
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
