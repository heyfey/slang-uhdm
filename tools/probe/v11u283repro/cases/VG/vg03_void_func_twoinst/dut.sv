// § progGenDupFirstSpan283
program prg ();
  if (1) begin : g
    function automatic void f_dup(); endfunction
  end
  function automatic void f_dup(); endfunction
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  prg u_q ();
  assign o = 32'd0;
endmodule
