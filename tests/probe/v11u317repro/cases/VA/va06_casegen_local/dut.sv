// § genIfaceInnerLocalKeepsBind317
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top #(parameter int P = 1) (input logic a, input logic b, output logic o);
  case (P)
    1: begin : g
      logic l;
      assign l = b;
      ifc u (.clk(~l | a));
    end
    default: begin : h
      ifc u (.clk(a));
    end
  endcase
  assign o = g.u.sig[0];
endmodule
