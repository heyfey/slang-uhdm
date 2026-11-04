// § ifaceInstFirstProcsShared283
interface ifc (input logic [3:0] d);
  logic [3:0] q;
  always_comb q = d + 1;
endinterface
module dut (input logic [3:0] x, y, output logic [3:0] o);
  ifc a (.d(x));
  ifc b (.d(y));
  assign o = a.q ^ b.q;
endmodule
