// v09 -- a FINAL construct in a PROGRAM's generate block.
program prg ();
  generate
    if (1) begin : g
      final begin
        $display("bye");
      end
    end
  endgenerate
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
