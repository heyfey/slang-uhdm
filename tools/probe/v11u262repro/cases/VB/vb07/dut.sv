// § genIpsOvrParamOwner262 (instance depth 2, a case-generate, the select an operand of a subtraction)
module leaf #(parameter int Width = 4, parameter int M = 1) (input logic [15:0] a, output logic [3:0] o);
  case (M)
    1: begin : c1
      assign o = a[0 +: Width] - 4'd1;
    end
    default: begin : cd
      assign o = a[3:0];
    end
  endcase
endmodule
module mid #(parameter int Width = 4) (input logic [15:0] a, output logic [3:0] o);
  leaf #(.Width(Width)) l(.a(a), .o(o));
endmodule
module top(input logic [15:0] a, output logic [3:0] o);
  mid #(.Width(4)) m(.a(a), .o(o));
endmodule
