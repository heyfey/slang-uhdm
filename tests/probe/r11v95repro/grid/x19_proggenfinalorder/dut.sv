// v11u93 x19 -- a BODY final BELOW the block's final.
program prg ();
  generate
    if (1) begin : g
      final $display("gen");
    end
  endgenerate
  final $display("body");
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
