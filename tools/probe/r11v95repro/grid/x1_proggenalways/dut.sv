// v11u93 x1 -- an ALWAYS_COMB inside a PROGRAM's generate block (legality probe).
program prg ();
  logic [31:0] w_plain;
  generate
    if (1) begin : g
      logic [31:0] w_gen;
      always_comb w_gen = 32'd12;
    end
  endgenerate
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
