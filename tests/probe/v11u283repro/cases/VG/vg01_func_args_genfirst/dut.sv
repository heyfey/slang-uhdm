// § progGenDupFirstSpan283
program prg ();
  if (1) begin : g
    function automatic int f_dup(input int a, input int b); return a + b; endfunction
  end
  function automatic int f_dup(input int a, input int b); return a - b; endfunction
  int r;
  initial r = f_dup(1, 2);
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
