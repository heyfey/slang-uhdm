// § progDefKeepsLastInstProcs283
interface ifc; logic [3:0] d; modport mp (input d); endinterface
program prg (ifc.mp m); int f; initial f = m.d; endprogram
module dut (output logic [31:0] o);
  ifc i1 (); ifc i2 ();
  prg u_1 (.m(i1));
  prg u_2 (.m(i2));
  assign o = 32'd0;
endmodule
