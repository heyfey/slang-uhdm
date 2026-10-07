// § progGenDupFirstSpan283
module m ();
  if (1) begin : g
    function automatic int f_dup(); return 1; endfunction
  end
  function automatic int f_dup(); return 2; endfunction
endmodule
module dut (output logic [31:0] o);
  m u_m ();
  assign o = 32'd0;
endmodule
