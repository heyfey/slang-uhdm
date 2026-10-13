// § genCaCastTdAliasScopedName304
module top #(parameter int K = 1) (input logic a, output logic [1:0] y);
  typedef logic [1:0] idx_t;
  case (K)
    1: begin : g
      assign y = idx_t'(a);
    end
    default: begin : d assign y = '0; end
  endcase
endmodule
