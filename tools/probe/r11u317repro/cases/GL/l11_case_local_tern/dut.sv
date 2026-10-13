// § genIfaceInnerLocalKeepsBind317
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top #(parameter P = 1) (input logic a, input logic b, input logic s, output logic o);
  case (P)
    1: begin : c
      logic l;
      assign l = s;
      ifc u (.clk(l ? a : b));
      assign o = u.sig[0];
    end
    default: begin : d
      assign o = a;
    end
  endcase
endmodule
