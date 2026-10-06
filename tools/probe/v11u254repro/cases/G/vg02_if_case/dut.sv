// § genCaPsBoundOpChain254 (operation part-select bounds in if and case generate scopes)
module top #(parameter int W = 4, parameter int S = 1) (input logic [15:0] a, output logic [3:0] o, output logic [3:0] p);
  if (S == 1) begin : gi
    assign o = a[W+3:W];
  end else begin : ge
    assign o = a[3:0];
  end
  case (S)
    1: begin : gc1 assign p = a[2*W-1:W]; end
    default: begin : gcd assign p = a[3:0]; end
  endcase
endmodule
