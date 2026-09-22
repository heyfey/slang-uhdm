// v11u93 x8 -- THE SAME SUBROUTINE NAME in the body and in the block.
program prg ();
  function automatic int f_dup(); return 3; endfunction
  generate
    if (1) begin : g
      function automatic int f_dup(); return 7; endfunction
    end
  endgenerate
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
