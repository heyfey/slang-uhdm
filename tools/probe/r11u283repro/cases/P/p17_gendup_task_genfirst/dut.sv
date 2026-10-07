// § progGenDupFirstSpan283
program prg ();
  if (1) begin : g
    task automatic t_dup(); endtask
  end
  task automatic t_dup(); endtask
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
