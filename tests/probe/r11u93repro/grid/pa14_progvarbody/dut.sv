// r11u93 pa14 -- THE CONTROL: the same variable declared in the program BODY.
program prg ();
  wire [31:0] w_plain = 32'd11;
  logic [31:0] v_body;
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
