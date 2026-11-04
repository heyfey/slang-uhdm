// § ifaceInstFirstProcsShared283
interface ifc;
  int q, r;
  initial q = 1;
  generate
    if (1) begin : g
      initial r = 2;
    end
  endgenerate
endinterface
module dut (output logic [31:0] o);
  ifc a (); ifc b ();
  assign o = 32'd0;
endmodule
