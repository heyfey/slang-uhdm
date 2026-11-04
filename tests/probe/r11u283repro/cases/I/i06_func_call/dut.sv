// § ifaceInstFirstProcsShared283
interface ifc;
  int q;
  function automatic int f(int a); return a + 1; endfunction
  initial q = f(2);
endinterface
module dut (output logic [31:0] o);
  ifc a (); ifc b ();
  assign o = 32'd0;
endmodule
