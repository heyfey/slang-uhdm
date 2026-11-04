// § tpCastUseBindsDefDefault206
module a08 #(parameter int K = 1, parameter int W = 2, parameter type t = logic [W-1:0]) (input logic s, output t o);
  t [3:0] x;
  case (K)
    1: begin : g1
      assign x[0] = s ? t'(1) : t'(2);
    end
    default: begin : g2
      assign x[0] = s ? t'(3) : t'(0);
    end
  endcase
  assign o = x[0];
endmodule
