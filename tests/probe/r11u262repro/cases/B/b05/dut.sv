// § genIpsOvrParamOwner262 (case-generate, width, whole right side)
module m #(parameter int Width = 32, parameter int E = 0) (input logic [7:0] a, output logic [2:0] q);
  case (E)
    0: begin : gc
      assign q = a[1+:Width];
    end
    default: begin : gd
      assign q = '0;
    end
  endcase
endmodule
module top(input logic [7:0] a, output logic [2:0] q);
  m #(.Width(3)) u (.*);
endmodule
