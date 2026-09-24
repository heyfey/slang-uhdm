// v11u93 v7 -- a genvar FOR loop with ZERO iterations in a PROGRAM.
program prg ();
  wire [31:0] w_plain = 32'd11;
  generate
    for (genvar i = 0; i < 0; i++) begin : g
      wire [31:0] w_loop = 32'd12;
    end
  endgenerate
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
