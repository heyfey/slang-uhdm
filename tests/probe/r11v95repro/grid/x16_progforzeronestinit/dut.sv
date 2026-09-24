// v11u93 x16 -- a zero-iteration loop holding a NESTED block with an initial.
program prg ();
  wire [31:0] w_plain = 32'd11;
  generate
    for (genvar i = 0; i < 0; i++) begin : g
      wire [31:0] w_outer = 32'd12;
      if (1) begin : gn
        wire [31:0] w_inner = 32'd13;
        initial $display("nested");
        function automatic int f_nested(); return 7; endfunction
      end
    end
  endgenerate
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
