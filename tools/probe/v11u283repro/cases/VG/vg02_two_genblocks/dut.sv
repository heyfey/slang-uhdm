// § progGenDupFirstSpan283
program prg ();
  if (1) begin : g1
    function automatic int f_dup(); return 1; endfunction
  end
  if (1) begin : g2
    function automatic int f_dup(); return 2; endfunction
  end
  function automatic int f_dup(); return 3; endfunction
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
