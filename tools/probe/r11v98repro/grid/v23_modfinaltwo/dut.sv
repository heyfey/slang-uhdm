// v23 -- TWO final constructs in one module generate block.
module sub ();
  generate
    if (1) begin : g
      final $display("one");
      final $display("two");
    end
  endgenerate
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
