// § ifaceHcVarSelWholeByInst319
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic [1:0][1:0] m, input logic [3:0] ck, input logic [1:0] s, input logic [1:0] t, input logic [1:0] k [2], input logic a, output logic o);
  for (genvar i = 0; i < 2; i++) begin : g
    ifc u (.clk(m[s][i]));
  end
  assign o = g[0].u.sig[0];
endmodule
