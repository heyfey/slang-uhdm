// r11u93 pa10 -- a MODULE instantiated inside a program's generate block.
module leaf (output logic [31:0] y);
  assign y = 32'd5;
endmodule
program prg ();
  wire [31:0] w_plain = 32'd11;
  generate
    if (1) begin : g
      leaf u_leaf ();
    end
  endgenerate
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
