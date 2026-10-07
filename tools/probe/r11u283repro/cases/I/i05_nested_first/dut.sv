// § ifaceInstFirstProcsShared283
interface ifc;
  int q;
  initial q = 1;
endinterface
module mid;
  ifc u_in ();
endmodule
module dut (output logic [31:0] o);
  mid u_mid ();
  ifc u_a ();
  assign o = 32'd0;
endmodule
