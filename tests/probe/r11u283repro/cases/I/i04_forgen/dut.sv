// § ifaceInstFirstProcsShared283
interface ifc;
  int q;
  initial q = 1;
endinterface
module dut (output logic [31:0] o);
  for (genvar i = 0; i < 2; i++) begin : g
    ifc u ();
  end
  assign o = 32'd0;
endmodule
