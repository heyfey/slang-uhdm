// r11u93 pa13 -- a generate-block net with the SAME NAME as a program body net.
program prg ();
  wire [31:0] w_dup = 32'd11;
  generate
    if (1) begin : g
      wire [31:0] w_dup = 32'd12;
    end
  endgenerate
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
