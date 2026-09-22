// r11u95 a20 -- THE FENCED HALF: a LOCALPARAM inside a program generate block.
program prg ();
  wire [31:0] w_plain = 32'd11;
  generate
    if (1) begin : g
      localparam int LP = 7;
      wire [31:0] w_gen = 32'd12;
    end
  endgenerate
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
