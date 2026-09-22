// r11u95 a7 -- a BODY function and a generate-block function (ORDER).
program prg ();
  function automatic int f_body(); return 3; endfunction
  generate
    if (1) begin : g
      function automatic int f_gen(); return 7; endfunction
    end
  endgenerate
  task automatic t_body(); endtask
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
