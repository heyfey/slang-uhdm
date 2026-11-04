// § genCaCastTdAliasScopedName304
module top #(parameter int K = 2) (input logic a, output logic [3:0] y);
  typedef logic [1:0] idx_t;
  case (K)
    2: begin : c2
      assign y[1:0] = idx_t'(a);
      if (1) begin : h
        assign y[3:2] = idx_t'(~a);
      end
    end
    default: begin : d assign y = '0; end
  endcase
endmodule
