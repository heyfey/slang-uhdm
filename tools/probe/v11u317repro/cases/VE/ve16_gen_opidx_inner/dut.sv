// § defGenSelInIdxLeaf317
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic [3:0] ck, input logic [2:0] k, input logic s, input logic a, output logic o);
  if (1) begin : g
    ifc u (.clk(ck[k[s+1]] & a));
  end
  assign o = g.u.sig[0];
endmodule
