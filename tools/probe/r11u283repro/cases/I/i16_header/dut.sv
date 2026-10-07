// § ifaceInstFirstProcsShared283
`include "ifc.svh"
module dut (output logic [31:0] o);
  ifc a (); ifc b ();
  assign o = 32'd0;
endmodule
