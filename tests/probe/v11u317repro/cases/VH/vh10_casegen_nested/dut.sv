// § defGenSelInIdxLeaf317
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top #(parameter int P = 2) (input logic [3:0] ck, input logic [1:0] k, input logic a, output logic o);
  case (P)
    2: begin : g
      ifc u (.clk(ck[k[1]] ^ a));
    end
    default: begin : g
      ifc u (.clk(a));
    end
  endcase
  assign o = g.u.sig[0];
endmodule
