// v11u93 x5 -- TWO instances, the initial ONLY in the generate block.
program prg ();
  wire [31:0] w_plain = 32'd11;
  generate
    if (1) begin : g
      initial begin
        $display("hi");
      end
    end
  endgenerate
endprogram
module dut (output logic [31:0] o);
  prg u_p1 ();
  prg u_p2 ();
  assign o = 32'd0;
endmodule
