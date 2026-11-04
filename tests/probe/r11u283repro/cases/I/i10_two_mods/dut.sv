// § ifaceInstFirstProcsShared283
interface ifc;
  int q;
  initial q = 1;
endinterface
module s1; ifc u1 (); endmodule
module s2; ifc u2 (); endmodule
module dut (output logic [31:0] o);
  s2 b ();
  s1 a ();
  assign o = 32'd0;
endmodule
