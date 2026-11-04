// § ifaceHcSelNamedByInst313
interface ifc2 (input logic clk, input logic [3:0] d, input logic e);
  logic [7:0] sig;
endinterface
module top (input logic [1:0] ck, input logic [7:0] dd, output logic o);
  ifc2 u (.clk(ck[0]), .d(dd[3:0]), .e(dd[ck]));
  assign o = u.sig[0];
endmodule
