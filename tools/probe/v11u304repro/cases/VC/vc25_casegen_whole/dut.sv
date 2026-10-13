// § genCaCastTdAliasScopedName304
module top #(parameter int M = 1) (input logic [3:0] a, output logic [1:0] y);
  typedef logic [1:0] idx_t;
  case (M)
    0: begin : g0 assign y = 2'b0; end
    default: begin : gd assign y = idx_t'(a) - 2'd1; end
  endcase
endmodule
