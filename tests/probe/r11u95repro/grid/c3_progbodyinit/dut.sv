// r11u95 c3 -- THE CONTROL: the same initial in the program BODY.
program prg ();
  wire [31:0] w_plain = 32'd11;
  wire [31:0] w_gen = 32'd12;
  initial begin
    $display("hi");
  end
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
