// r11u95 c5 -- THE CONTROL: the same class in the program BODY.
program prg ();
  wire [31:0] w_plain = 32'd11;
  class C; int x; endclass
  wire [31:0] w_gen = 32'd12;
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
