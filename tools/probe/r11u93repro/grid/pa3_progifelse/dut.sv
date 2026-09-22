// r11u93 pa3 -- a program generate if/else: BOTH arms declare a net.
program prg ();
  wire [31:0] w_plain = 32'd11;
  generate
    if (0) begin : g
      wire [31:0] w_then = 32'd12;
    end else begin : h
      wire [31:0] w_else = 32'd13;
    end
  endgenerate
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
