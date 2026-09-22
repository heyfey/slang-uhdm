// r11u93 pa9 -- a localparam inside a program's generate block.
program prg ();
  wire [31:0] w_plain = 32'd11;
  generate
    if (1) begin : g
      localparam int LP = 7;
      wire [31:0] w_gen = LP;
    end
  endgenerate
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
