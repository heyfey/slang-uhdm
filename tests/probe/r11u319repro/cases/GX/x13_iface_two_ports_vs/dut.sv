// § ifaceHcVarSelWholeByInst319
interface ifc2 (input logic clk, input logic rst);
  logic sig;
endinterface
module top (input logic [1:0][1:0] m, input logic [3:0] ck, input logic [1:0] s, input logic [1:0] t, input logic a, output logic o);
  ifc2 u (.clk(m[s][1]), .rst(ck[$signed(t)]));
  assign o = u.sig;
endmodule
