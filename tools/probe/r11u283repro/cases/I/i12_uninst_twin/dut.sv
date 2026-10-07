// § ifaceInstFirstProcsShared283
interface ifc;
  int q;
  initial q = 1;
endinterface
interface ifu;
  int q;
  initial q = 1;
endinterface
module dut (output logic [31:0] o);
  ifc a (); ifc b ();
  assign o = 32'd0;
endmodule
