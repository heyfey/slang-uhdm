// § ifaceInstFirstProcsShared283
interface ifc;
  int q;
  initial begin : blk
    int t;
    t = 3;
    q = t;
  end
endinterface
module dut (output logic [31:0] o);
  ifc a (); ifc b ();
  assign o = 32'd0;
endmodule
