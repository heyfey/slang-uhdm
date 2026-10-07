// § ifaceInstFirstProcsShared283
interface ifc #(parameter int W = 4);
  logic [W-1:0] q;
  initial q = W;
endinterface
module dut (output logic [31:0] o);
  ifc #(4) a ();
  ifc #(.W(8)) b ();
  assign o = 32'd0;
endmodule
