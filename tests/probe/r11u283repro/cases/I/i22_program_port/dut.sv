// § ifacePortViewNoProcs283
interface ifc;
  int q;
  initial q = 1;
endinterface
program prg (ifc m); int f; initial f = m.q; endprogram
module dut (output logic [31:0] o);
  ifc a ();
  prg p (.m(a));
  assign o = 32'd0;
endmodule
