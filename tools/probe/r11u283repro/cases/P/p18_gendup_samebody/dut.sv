// § progGenDupFirstSpan283
program prg ();
  if (1) begin : g
    function automatic int f_dup(); return 3; endfunction
  end
  function automatic int f_dup(); return 3; endfunction
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
