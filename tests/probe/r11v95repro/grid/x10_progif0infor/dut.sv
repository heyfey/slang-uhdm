// v11u93 x10 -- an UNTAKEN if(0) inside a two-iteration loop.
program prg ();
  wire [31:0] w_plain = 32'd11;
  generate
    for (genvar i = 0; i < 2; i++) begin : g
      if (0) begin : gf
        wire [31:0] w_false = 32'd13;
        initial $display("false");
        function automatic int f_false(); return 1; endfunction
      end
    end
  endgenerate
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
