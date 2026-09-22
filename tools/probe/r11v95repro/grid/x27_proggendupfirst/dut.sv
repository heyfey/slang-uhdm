// v11u93 x27 -- the DUPLICATE name, generate block FIRST, body second.
program prg ();
  generate
    if (1) begin : g
      function automatic int f_dup(); return 7; endfunction
    end
  endgenerate
  function automatic int f_dup(); return 3; endfunction
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
