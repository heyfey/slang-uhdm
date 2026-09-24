// v11u93 x6 -- LAW B x the TASK/FUNC face: a zero-iteration loop's subroutines.
program prg ();
  wire [31:0] w_plain = 32'd11;
  generate
    for (genvar i = 0; i < 0; i++) begin : g
      function automatic int f_zero(); return 7; endfunction
      task automatic t_zero(); endtask
    end
  endgenerate
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
