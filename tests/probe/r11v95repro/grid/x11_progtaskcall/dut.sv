// v11u93 x11 -- a BODY initial CALLS the generate block's function.
program prg ();
  wire [31:0] w_plain = 32'd11;
  generate
    if (1) begin : g
      function automatic int f_gen(); return 7; endfunction
    end
  endgenerate
  initial begin
    $display("%0d", g.f_gen());
  end
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
