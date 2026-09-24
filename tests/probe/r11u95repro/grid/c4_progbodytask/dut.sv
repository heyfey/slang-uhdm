// r11u95 c4 -- THE CONTROL: the same function and task in the program BODY.
program prg ();
  wire [31:0] w_plain = 32'd11;
  function automatic int f_gen(); return 7; endfunction
  task automatic t_gen(); endtask
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
