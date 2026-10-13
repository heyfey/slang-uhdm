// § ifaceHcOpSelByInst315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top #(parameter int K = 1) (input logic [1:0] ck, input logic s, output logic o);
  case (K)
    1: begin : g
      ifc u (.clk(ck[s] & ~ck[0]));
    end
    default: begin : h
    end
  endcase
  assign o = g.u.sig[0];
endmodule
