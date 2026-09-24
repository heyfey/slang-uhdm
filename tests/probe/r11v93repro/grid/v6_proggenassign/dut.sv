// v11u93 v6 -- a standalone CONTINUOUS ASSIGN inside a PROGRAM's generate block.
program prg ();
  wire [31:0] w_plain;
  generate
    if (1) begin : g
      wire [31:0] w_gen;
      assign w_gen = 32'd12;
    end
  endgenerate
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
