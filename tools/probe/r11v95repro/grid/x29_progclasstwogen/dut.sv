// v11u93 x29 -- TWO generate blocks, one body class between them.
program prg ();
  generate
    if (1) begin : g1
      class Cg1; int a; endclass
    end
  endgenerate
  class Cbody; int b; endclass
  generate
    if (1) begin : g2
      class Cg2; int c; endclass
    end
  endgenerate
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
