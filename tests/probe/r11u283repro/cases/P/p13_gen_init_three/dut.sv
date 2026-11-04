// § progDefKeepsLastInstProcs283
program prg ();
  int w;
  if (1) begin : g
    initial begin w = 1; end
  end
endprogram
module dut (output logic [31:0] o);
  prg u_1 ();
  prg u_2 ();
  prg u_3 ();
  assign o = 32'd0;
endmodule
