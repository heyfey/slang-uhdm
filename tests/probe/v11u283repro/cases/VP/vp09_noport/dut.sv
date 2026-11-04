// § progDefKeepsLastInstProcs283
program prg; int f; initial begin f = 1; f = f + 2; end endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  prg u_q ();
  assign o = 32'd0;
endmodule
