// § defGenSelInIdxLeaf317
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top #(parameter logic [1:0] K = 2'b01) (input logic [3:0] ck, input logic a, output logic o);
  if (1) begin : g
    ifc u (.clk(ck[K[0]] & a));
  end
  assign o = g.u.sig[0];
endmodule
