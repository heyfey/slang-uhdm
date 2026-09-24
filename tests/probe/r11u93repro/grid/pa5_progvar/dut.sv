// r11u93 pa5 -- a program generate block declaring a VARIABLE.
program prg ();
  wire [31:0] w_plain = 32'd11;
  generate
    if (1) begin : g
      logic [31:0] v_gen;
    end
  endgenerate
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
