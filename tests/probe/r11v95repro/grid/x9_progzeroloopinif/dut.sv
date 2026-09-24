// v11u93 x9 -- a ZERO-iteration loop nested INSIDE an if-generate.
program prg ();
  wire [31:0] w_plain = 32'd11;
  generate
    if (1) begin : g
      wire [31:0] w_g = 32'd12;
      for (genvar i = 0; i < 0; i++) begin : gz
        wire [31:0] w_zero = 32'd13;
        initial $display("zero");
      end
    end
  endgenerate
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
