// § ifacePortViewNoProcs283
interface ifc;
  int q;
  initial q = 1;
endinterface
module sub (ifc m [2], output logic [31:0] o); assign o = m[0].q; endmodule
module dut (output logic [31:0] o);
  ifc u [2] ();
  sub s (.m(u), .o(o));
endmodule
