// § ifacePortViewNoProcs283
interface inner;
  int q;
  initial q = 1;
endinterface
interface outer (inner i);
  int r;
  initial r = 2;
endinterface
module dut (output logic [31:0] o);
  inner a ();
  outer b (.i(a));
  assign o = 32'd0;
endmodule
