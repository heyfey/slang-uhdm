// § defGenCastInIdxLeaf317
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top #(parameter int W = 2) (input logic [3:0] ck, input logic [2:0] s, input logic a, output logic o);
  if (1) begin : g
    ifc u (.clk(ck[W'(s)] | a));
  end
  assign o = g.u.sig[0];
endmodule
