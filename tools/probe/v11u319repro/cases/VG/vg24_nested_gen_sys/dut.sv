// § defGenSysInIdxLeaf319
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic [1:0][1:0] m, input logic [3:0] ck, input logic [1:0] s, input logic [1:0] t, input logic [1:0] k [2], input logic a, output logic o);
  if (1) begin : g
    if (1) begin : h
      ifc u (.clk(ck[$unsigned(s)] | a));
    end
  end
  assign o = g.h.u.sig[0];
endmodule
