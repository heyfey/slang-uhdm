// § defGenSelInIdxLeaf317
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic [3:0] ck, input logic [3:0] k, input logic a, output logic o);
  if (1) begin : g
    ifc u (.clk(ck[k[3]] & ck[k[2]] & a));
  end
  assign o = g.u.sig[0];
endmodule
